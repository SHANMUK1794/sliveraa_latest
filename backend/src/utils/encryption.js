const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * Encryption Utility for Surepass API
 * Required when "Encryption is Active" in Surepass Dashboard
 */
class EncryptionUtils {
  constructor() {
    // Read public key and handle potential Railway formatting or naming issues
    let key = process.env.SUREPASS_PUBLIC_KEY || process.env['SUREPASS PUBLIC KEY'];
    
    if (key) {
      // Fix common issue where newlines are escaped as \n text
      key = key.replace(/\\n/g, '\n');
      
      // Ensure it has the proper headers if they are missing
      if (!key.includes('-----BEGIN PUBLIC KEY-----')) {
        key = `-----BEGIN PUBLIC KEY-----\n${key}\n-----END PUBLIC KEY-----`;
      }
      this.publicKey = key;
      console.log('EncryptionUtils: Public key loaded and formatted.');
    } else {
      console.warn('EncryptionUtils: SUREPASS_PUBLIC_KEY not found in environment variables.');
      this.publicKey = null;
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
