const axios = require('axios');
const crypto = require('crypto');

class PaymentService {
  constructor() {
    this.appId = process.env.CASHFREE_APP_ID;
    this.secretKey = process.env.CASHFREE_SECRET_KEY;
    this.environment = process.env.CASHFREE_ENVIRONMENT || 'SANDBOX';
    
    this.baseUrl = this.environment === 'PRODUCTION' 
      ? 'https://api.cashfree.com/pg' 
      : 'https://sandbox.cashfree.com/pg';
  }

  get isAvailable() {
    // Return true if credentials are set
    return Boolean(this.appId && this.secretKey);
  }

  getHeaders() {
    return {
      'x-api-version': '2023-08-01',
      'x-client-id': this.appId,
      'x-client-secret': this.secretKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  /**
   * Create Cashfree Order
   * @param {number} amount - Amount in INR (Cashfree accepts floats like 10.50, not paise)
   * @param {string} currency - currency (default INR)
   * @param {string} receipt - receipt id / order id
   * @param {object} customer - Customer Details { customer_id, customer_phone, customer_email, customer_name }
   * @returns {Promise<any>}
   */
  async createOrder(amount, customer, currency = 'INR', receipt = 'receipt_' + Date.now()) {
    if (!this.isAvailable) {
      throw new Error('Payment service is not configured');
    }

    try {
      const response = await axios.post(`${this.baseUrl}/orders`, {
        order_amount: amount,
        order_currency: currency,
        order_id: receipt,
        customer_details: {
          customer_id: customer.id || 'CUST_123',
          customer_phone: customer.phone || '9999999999',
          customer_email: customer.email || 'customer@example.com',
          customer_name: customer.name || 'Customer'
        },
        order_meta: {
          return_url: 'https://silvra.in/payment/status?order_id={order_id}',
        }
      }, {
        headers: this.getHeaders()
      });

      return response.data; // Includes payment_session_id
    } catch (error) {
      console.error('Cashfree Create Order Error:', error.response?.data || error.message);
      throw new Error('Failed to create payment order');
    }
  }

  /**
   * Fetch Cashfree Order by order_id
   */
  async getOrder(orderId) {
    if (!this.isAvailable) return null;
    
    try {
      const response = await axios.get(`${this.baseUrl}/orders/${orderId}`, {
        headers: this.getHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Cashfree Get Order Error:', error.response?.data || error.message);
      return null;
    }
  }

  /**
   * Verify Webhook Signature
   * @param {string} rawBody - Raw body of the webhook request
   * @param {string} signature - x-webhook-signature header
   * @param {string} timestamp - x-webhook-timestamp header
   */
  verifyWebhookSignature(rawBody, signature, timestamp) {
    if (!this.isAvailable) throw new Error('Payment service is not configured');

    const expectedSignature = crypto
      .createHmac('sha256', this.secretKey)
      .update(timestamp + rawBody)
      .digest('base64');

    return expectedSignature === signature;
  }
}

module.exports = new PaymentService();
