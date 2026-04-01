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
   * Helper to send raw (unencrypted) request 
   */
  async _postRaw(path, data) {
    try {
      const response = await axios.post(`${this.baseUrl}${path}`, data, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error(`Surepass API Raw Error [${path}]:`, error.response?.data || error.message);
      throw error;
    }
  }
  async createDigiLockerSession(customId) {
    try {
      // Official Digiboost Initialize Payload (Minimal)
      const payload = {
        data: {
          signup_flow: true,
          skip_main_screen: false,
          redirect_url: 'https://silvra-kyc-callback.local/success'
        }
      };

      const response = await axios.post(`${this.baseUrl}/digilocker/initialize`, payload, {
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
   * PAN Verification (Comprehensive)
   */
  async verifyPanComprehensive(idNumber, fullName, dob) {
    return await this._postRaw('/pan/pan-comprehensive', {
      id_number: idNumber,
      full_name: fullName,
      dob: dob
    });
  }

  /**
   * PAN Verification (Basic)
   */
  async verifyPan(idNumber) {
    return await this._postRaw('/pan/pan-verification', {
      id_number: idNumber
    });
  }

  /**
   * Fetch DigiLocker Verification Result 
   * (Standard download-aadhaar API after WebSDK success)
   */
  async getDigiLockerResult(clientId) {
    try {
      const response = await axios.get(`${this.baseUrl}/digilocker/download-aadhaar/${clientId}`, {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Surepass Result Fetch Failed:', error.response?.data || error.message);
      throw error;
    }
  }
}

module.exports = new KycService();
