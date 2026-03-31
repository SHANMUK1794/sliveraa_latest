const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * Encryption Utility for Surepass API
 * Required when "Encryption is Active" in Surepass Dashboard
 */
class EncryptionUtils {
  constructor() {
    // Path to the public key provided by the user
    this.publicKeyPath = 'C:\\Users\\user\\Desktop\\SILVRA S\\sandbox_server_key.pem';
    try {
      this.publicKey = fs.readFileSync(this.publicKeyPath, 'utf8');
    } catch (error) {
      console.error('EncryptionUtils: Failed to read public key at', this.publicKeyPath);
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
          padding: crypto.constants.RSA_PKCS1_PADDING, // Standard for Surepass
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
