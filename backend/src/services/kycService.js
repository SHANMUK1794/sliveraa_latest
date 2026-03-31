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
   * Create DigiLocker WebSDK Session
   * @param {string} customId - Unique ID for the session (e.g. userId)
   */
  async createDigiLockerSession(customId) {
    try {
      // Try the digilocker slug first
      return await this._post('/digilocker/create-session', {
        custom_id: customId,
        redirect_url: 'https://silvras.com/kyc-callback'
      });
    } catch (error) {
      // If that fails, try the digiboost slug seen in your GitHub link
      console.log('DigiLocker endpoint failed, trying DigiBoost fallback...');
      return await this._post('/digiboost/create-session', {
        custom_id: customId,
        redirect_url: 'https://silvras.com/kyc-callback'
      });
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
