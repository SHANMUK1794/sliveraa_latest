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
        data: encryptedData
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
      // Official Digiboost Initialize Endpoint
      const response = await this._post('/digilocker/initialize', {
        signup_flow: true,
        skip_main_screen: false,
        custom_id: customId
      });
      
      // The guide says this returns { data: { token, client_id, ... } }
      return response.data;
    } catch (error) {
      console.error('Digiboost Initialization Failed:', error.response?.data || error.message);
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
