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
    let rawKey = process.env.SUREPASS_PUBLIC_KEY || process.env['SUREPASS PUBLIC KEY'];
    
    if (rawKey) {
      try {
        console.log('EncryptionUtils: Starting X-Ray Key Analysis...');
        
        // Debug: Log the first 30 character codes to reveal hidden spaces/BOMs
        const charCodes = [];
        for (let i = 0; i < Math.min(30, rawKey.length); i++) {
          charCodes.push(rawKey.charCodeAt(i));
        }
        console.log(`EncryptionUtils: Key Start CharCodes: ${charCodes.join(',')}`);

        // 1. Aggressive Scrub: Remove ALL whitespace, quotes, backslashes and "n" characters
        // We want to extract just the raw base64 body if possible
        let body = rawKey.replace(/-----BEGIN [^-]+-----|-----END [^-]+-----/g, '')
                          .replace(/\\n/g, '')
                          .replace(/\\r/g, '')
                          .replace(/[\s"'\\]/g, '') // Remove spaces, quotes, backslashes
                          .trim();
        
        console.log(`EncryptionUtils: Cleaned Base64 Body Length: ${body.length} chars`);

        // 2. Reconstruct a perfect PEM string
        const finalKey = `-----BEGIN PUBLIC KEY-----\n${body}\n-----END PUBLIC KEY-----`;

        // 3. Decoding using specific SPKI/PEM format
        this.publicKey = crypto.createPublicKey({
          key: finalKey,
          format: 'pem',
          type: 'spki'
        });
        
        console.log('EncryptionUtils: RSA Public Key successfully reconstructed and ready.');
      } catch (err) {
        console.error('EncryptionUtils: CRITICAL - Reconstruction Failed!');
        console.error('Error Details:', err.message);
        console.error('Key Preview:', rawKey.substring(0, 20) + '...' + rawKey.substring(rawKey.length - 10));
        this.publicKey = null;
      }
    } else {
      console.warn('EncryptionUtils: SUREPASS_PUBLIC_KEY not found in environment variables.');
      this.publicKey = null;
    }
  }

  /**
   * Encrypt data using RSA-OAEP with SHA-256
   * @param {Object} data - The payload to encrypt
   * @returns {string|null} - Base64 encrypted string
   */
  encrypt(data) {
    if (!this.publicKey) {
      console.error('EncryptionUtils: Public key not loaded. Cannot encrypt.');
      return null;
    }

    try {
      const jsonString = JSON.stringify(data);
      const buffer = Buffer.from(jsonString);
      
      console.log(`EncryptionUtils: Encrypting buffer of size ${buffer.length} bytes...`);
      
      // Switching to PKCS1 Padding for 1024-bit Sandbox Keys
      // This increases capacity to 117 bytes (vs 86 for OAEP), letting our 111-byte payload fit.
      const encrypted = crypto.publicEncrypt(
        {
          key: this.publicKey,
          padding: crypto.constants.RSA_PKCS1_PADDING
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
