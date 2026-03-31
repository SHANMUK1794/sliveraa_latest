const axios = require('axios');

class OtpService {
  constructor() {
    const { MSG91_AUTH_KEY } = process.env;

    if (MSG91_AUTH_KEY) {
      this.authKey = MSG91_AUTH_KEY;
      // Using Flow API which is more robust for DLT templates
      this.url = 'https://api.msg91.com/api/v5/flow/';
    } else {
      this.authKey = null;
      this.url = null;
      console.warn('OtpService: MSG91_AUTH_KEY not set. OTP delivery via SMS is disabled.');
    }
  }

  get isAvailable() {
    return this.authKey !== null;
  }

  /**
   * Send OTP using Flow API
   * @param {string} mobile - Recipient mobile number
   * @param {string} code - Generated OTP code
   * @returns {Promise<any>}
   */
  async sendOtp(mobile, code) {
    if (!this.authKey) {
      throw new Error('OTP service is not configured');
    }
    try {
      const response = await axios.post(this.url, {
        template_id: '69c6360a2ce9b288c7035137',
        short_url: '1',
        recipients: [
          {
            mobiles: mobile,
            numeric: code // Matches ##numeric## in your DLT template
          }
        ]
      }, {
        headers: {
          'authkey': this.authKey,
          'Content-Type': 'application/json'
        },
      });
      return response.data;
    } catch (error) {
      console.error('MSG91 Flow Error:', error.response?.data || error.message);
      throw new Error('OTP delivery failed');
    }
  }

  async verifyOtp(mobile, code) {
    // Verification is handled by our database logic since we generate it
    return true; 
  }
}

module.exports = new OtpService();
