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
        console.log('EncryptionUtils: Attempting to decode Public Key...');
        
        // 1. Aggressive clean: Fix escaped newlines, remove quotes, and trim
        let cleanedKey = rawKey.replace(/\\n/g, '\n')
                               .replace(/\\r/g, '')
                               .replace(/"/g, '') // Remove double quotes
                               .replace(/'/g, '') // Remove single quotes
                               .trim();
        
        console.log(`EncryptionUtils: Cleaned Key Length: ${cleanedKey.length} chars`);

        // 2. Ensure standard SPKI headers if totally naked base64
        if (!cleanedKey.startsWith('-----BEGIN')) {
          console.log('EncryptionUtils: Wrapping naked base64 in PEM headers...');
          // Remove ALL whitespace from raw base64 before wrapping
          const nakedBase64 = cleanedKey.replace(/\s/g, '');
          cleanedKey = `-----BEGIN PUBLIC KEY-----\n${nakedBase64}\n-----END PUBLIC KEY-----`;
        }

        // 3. Decoding
        this.publicKey = crypto.createPublicKey({
          key: cleanedKey,
          format: 'pem'
        });
        
        console.log('EncryptionUtils: RSA Public Key successfully decoded and ready.');
      } catch (err) {
        console.error('EncryptionUtils: CRITICAL - Failed to decode Public Key!');
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
      const buffer = Buffer.from(JSON.stringify(data));
      
      // Surepass requirement: RSA-OAEP with SHA-256 for both OAEP and MGF1
      const encrypted = crypto.publicEncrypt(
        {
          key: this.publicKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256',
          mgf1Hash: 'sha256' // CRITICAL: Surepass requires SHA-256 for MGF1
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
