const axios = require('axios');

class KycService {
  constructor() {
    const { SUREPASS_API_TOKEN, SUREPASS_SBT_BASE_URL } = process.env;

    if (SUREPASS_API_TOKEN) {
      this.token = SUREPASS_API_TOKEN;
      this.baseUrl = SUREPASS_SBT_BASE_URL || 'https://sandbox.surepass.app/api/v1';
    } else {
      this.token = null;
      this.baseUrl = null;
      console.warn('KycService: SUREPASS_API_TOKEN not set. KYC verification features are disabled.');
    }
  }

  get isAvailable() {
    return this.token !== null;
  }

  /**
   * Aadhaar Verification (Standard REST API)
   * @param {string} idNumber - Aadhaar Number
   * @returns {Promise<any>}
   */
  async verifyAadhaar(idNumber) {
    if (!this.token) {
      throw new Error('KYC service is not configured');
    }
    try {
      const response = await axios.post(`${this.baseUrl}/aadhaar-v2/generate-otp`, {
        id_number: idNumber
      }, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Surepass Aadhaar OTP Error:', error.response?.data || error.message);
      throw new Error('Aadhaar OTP generation failed');
    }
  }

  /**
   * Verify Aadhaar OTP
   * @param {string} clientId - Client ID from generate-otp
   * @param {string} otp - OTP code
   * @returns {Promise<any>}
   */
  async submitAadhaarOtp(clientId, otp) {
    if (!this.token) {
      throw new Error('KYC service is not configured');
    }
    try {
      const response = await axios.post(`${this.baseUrl}/aadhaar-v2/submit-otp`, {
        client_id: clientId,
        otp: otp
      }, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Surepass Aadhaar Submit Error:', error.response?.data || error.message);
      throw new Error('Aadhaar verification submission failed');
    }
  }

  /**
   * PAN Verification
   * @param {string} idNumber - PAN Number
   * @returns {Promise<any>}
   */
  async verifyPan(idNumber) {
    if (!this.token) {
      throw new Error('KYC service is not configured');
    }
    try {
      const response = await axios.post(`${this.baseUrl}/pan/pan-verification`, {
        id_number: idNumber
      }, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Surepass PAN Error:', error.response?.data || error.message);
      throw new Error('PAN verification failed');
    }
  }
}

module.exports = new KycService();
