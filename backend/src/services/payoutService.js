const axios = require('axios');

class PayoutService {
  constructor() {
    this.appId = process.env.CASHFREE_PAYOUT_APP_ID;
    this.secretKey = process.env.CASHFREE_PAYOUT_SECRET_KEY;
    this.environment = process.env.CASHFREE_PAYOUT_ENVIRONMENT || 'SANDBOX';
    
    // Cashfree Payout uses a different base URL than PG
    this.baseUrl = this.environment === 'PRODUCTION' 
      ? 'https://payout-api.cashfree.com/payout/v1' 
      : 'https://payout-gamma.cashfree.com/payout/v1';
  }

  get isAvailable() {
    return Boolean(this.appId && this.secretKey);
  }

  getHeaders() {
    return {
      'X-Client-Id': this.appId,
      'X-Client-Secret': this.secretKey,
      'Content-Type': 'application/json'
    };
  }

  /**
   * Verify token for Cashfree Payout API (Required for v1 API)
   */
  async authenticate() {
    try {
      const response = await axios.post(`${this.baseUrl}/authorize`, {}, {
        headers: this.getHeaders()
      });
      return response.data.data.token;
    } catch (error) {
      console.error('Cashfree Payout Auth Error:', error.response?.data || error.message);
      throw new Error('Failed to authenticate with Cashfree Payouts');
    }
  }

  /**
   * Add a beneficiary to Cashfree
   */
  async addBeneficiary(token, beneficiaryDetails) {
    try {
      const response = await axios.post(`${this.baseUrl}/addBeneficiary`, {
        beneId: beneficiaryDetails.id,
        name: beneficiaryDetails.name,
        email: beneficiaryDetails.email || 'user@example.com',
        phone: beneficiaryDetails.phone,
        bankAccount: beneficiaryDetails.accountNumber,
        ifsc: beneficiaryDetails.ifsc,
        address1: 'Silvra App User'
      }, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      // 200 OK means either added or already exists
      if (response.data.subCode === '200' || response.data.subCode === '409') {
        return true;
      }
      throw new Error(response.data.message);
    } catch (error) {
      if (error.response?.data?.subCode === '409') {
        return true; // Already exists
      }
      console.error('Cashfree Add Beneficiary Error:', error.response?.data || error.message);
      throw new Error('Failed to add beneficiary for payout');
    }
  }

  /**
   * Initiate a Transfer (Payout)
   * @param {number} amount - Amount in INR
   * @param {string} transferId - Unique transaction ID
   * @param {string} beneId - Beneficiary ID
   */
  async requestTransfer(amount, transferId, beneId) {
    if (!this.isAvailable) throw new Error('Payout service is not configured');

    const token = await this.authenticate();
    
    try {
      const response = await axios.post(`${this.baseUrl}/requestTransfer`, {
        beneId: beneId,
        amount: amount,
        transferId: transferId,
        transferMode: 'banktransfer', // Uses IMPS/NEFT automatically
        remarks: 'Silvra Withdrawal'
      }, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.data.subCode === '200') {
        return response.data.data;
      } else {
        throw new Error(response.data.message || 'Transfer request failed');
      }
    } catch (error) {
      console.error('Cashfree Request Transfer Error:', error.response?.data || error.message);
      throw new Error(error.response?.data?.message || 'Failed to initiate payout');
    }
  }
}

module.exports = new PayoutService();
