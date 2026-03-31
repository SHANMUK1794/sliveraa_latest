const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * Encryption Utility for Surepass API
 * Required when "Encryption is Active" in Surepass Dashboard
 */
class EncryptionUtils {
  constructor() {
    this.token = process.env.SUREPASS_API_TOKEN;
    this.baseUrl = process.env.SUREPASS_BASE_URL || 'https://sandbox.surepass.app/api/v1';

    if (!this.token) {
      console.warn('KycService: SUREPASS_API_TOKEN not found in environment variables.');
    }
  }

  /**
   * Encrypt a JSON payload using RSA Public Key
   * @param {Object} data - The JSON object to encrypt
   * @returns {string|null} - Base64 encoded encrypted string
   */
  encrypt(data) {
    if (!this.publicKey) {
      console.error('EncryptionUtils: Public key not loaded. Cannot encrypt.');
      return null;
    }

    try {
      const buffer = Buffer.from(JSON.stringify(data));
      const encrypted = crypto.publicEncrypt(
        {
          key: this.publicKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256',
        },
        buffer
      );
      return encrypted.toString('base64');
    } catch (error) {
      console.error('EncryptionUtils: Encryption failed:', error.message);
      return null;
    }
  }
}

module.exports = new EncryptionUtils();
