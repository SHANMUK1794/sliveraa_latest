const axios = require('axios');
const encryption = require('../utils/encryption');

class KycService {
  constructor() {
    this.token = process.env.SUREPASS_API_TOKEN;
    this.baseUrl = process.env.SUREPASS_BASE_URL || 'https://sandbox.surepass.app/api/v1';

    if (!this.token) {
      console.warn('KycService: SUREPASS_API_TOKEN not found in environment variables.');
    }
  }

  get isAvailable() {
    return this.token !== null;
  }

  /**
   * Helper to send encrypted request
   */
  async _post(path, data) {
    const encryptedData = encryption.encrypt(data);
    if (!encryptedData) throw new Error('Failed to encrypt KYC payload');

    try {
      const response = await axios.post(`${this.baseUrl}${path}`, {
        sp_data: encryptedData // Surepass requirement: Encryption must wrap payload in 'sp_data'
      }, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error(`Surepass API Error [${path}]:`, error.response?.data || error.message);
      // Re-throw the error so the controller can catch it
      throw error;
    }
  }

  /**
   * Initialize DigiBoost/DigiLocker WebSDK Session
   * @param {string} customId - Unique ID for the session (e.g. userId)
   */
  async createDigiLockerSession(customId) {
    try {
      // Official Digiboost Initialize Payload (Minimal)
      const payload = {
        data: {
          signup_flow: true,
          skip_main_screen: false,
          // custom_id is not required by docs but useful for tracking if the API allows it
          custom_id: typeof customId === 'object' ? (customId.id || customId.userId || JSON.stringify(customId)) : String(customId),
          redirect_url: 'https://silvras.com/kyc-callback'
        }
      };

      const encryptedData = encryption.encrypt(payload);
      if (!encryptedData) throw new Error('Failed to encrypt KYC payload');
      
      // Perform direct post to avoid the double-encryption in the _post helper
      const response = await axios.post(`${this.baseUrl}/digilocker/initialize`, {
        sp_data: encryptedData
      }, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      
      return response.data;
    } catch (error) {
      if (error.response?.data) {
        console.error('Surepass Initialization Failed:', error.response.data);
      } else {
        console.error('Surepass Initialization Failed:', error.message);
      }
      throw error;
    }
  }

  /**
   * Aadhaar Verification (Standard REST API)
   */
  async verifyAadhaar(idNumber) {
    return await this._post('/aadhaar-v2/generate-otp', {
      id_number: idNumber
    });
  }

  /**
   * Verify Aadhaar OTP
   */
  async submitAadhaarOtp(clientId, otp) {
    return await this._post('/aadhaar-v2/submit-otp', {
      client_id: clientId,
      otp: otp
    });
  }

  /**
   * PAN Verification
   */
  async verifyPan(idNumber) {
    return await this._post('/pan/pan-verification', {
      id_number: idNumber
    });
  }
}

module.exports = new KycService();
