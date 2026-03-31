const axios = require('axios');
const encryption = require('../utils/encryption');

class KycService {
  constructor() {
    this.token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc3NDg1MTEyOCwianRpIjoiZDc4ZTQzMDUtZjk0NC00NWUwLTk4OTQtYTgwN2I2OWMzM2Y4IiwidHlwZSI6ImFjY2VzcyIsImlkZW50aXR5IjoiZGV2LnNpbHZyYXZlbnVfMTQ4NTA0QHN1cmVwYXNzLmlvIiwibmJmIjoxNzc0ODUxMTI4LCJleHAiOjE3Nzc0NDMxMjgsImVtYWlsIjoic2lsdnJhdmVudV8xNDg1MDRAc3VyZXBhc3MuaW8iLCJ0ZW5hbnRfaWQiOiJtYWluIiwidXNlcl9jbGFpbXMiOnsic2NvcGVzIjpbInVzZXIiXX19.LcNPfaqFxe_hI_IxdRnJ0eEb5Yd9X-H9gxnlvcvVMrs';
    this.baseUrl = 'https://sandbox.surepass.app/api/v1';
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

    const response = await axios.post(`${this.baseUrl}${path}`, {
      data: encryptedData
    }, {
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json'
      }
    });

    return response.data;
  }

  /**
   * Create DigiLocker WebSDK Session
   * @param {string} customId - Unique ID for the session (e.g. userId)
   */
  async createDigiLockerSession(customId) {
    return await this._post('/digilocker/create-session', {
      custom_id: customId,
      redirect_url: 'https://silvras.com/kyc-callback' // Temporary callback
    });
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
