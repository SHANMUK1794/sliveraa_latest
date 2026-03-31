const Razorpay = require('razorpay');
const crypto = require('crypto');

class PaymentService {
  constructor() {
    const { RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET } = process.env;

    if (RAZORPAY_KEY_ID && RAZORPAY_KEY_SECRET) {
      this.razorpay = new Razorpay({
        key_id: RAZORPAY_KEY_ID,
        key_secret: RAZORPAY_KEY_SECRET,
      });
    } else {
      this.razorpay = null;
      console.warn('PaymentService: RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET not set. Payment features are disabled.');
    }
  }

  get isAvailable() {
    return this.razorpay !== null;
  }

  /**
   * Create Razorpay Order
   * @param {number} amount - Amount in paise (e.g., 10000 for 100 INR)
   * @param {string} currency - currency (default INR)
   * @param {string} receipt - receipt id
   * @returns {Promise<any>}
   */
  async createOrder(amount, currency = 'INR', receipt = 'receipt_' + Date.now()) {
    if (!this.razorpay) {
      throw new Error('Payment service is not configured');
    }
    try {
      const order = await this.razorpay.orders.create({
        amount,
        currency,
        receipt,
      });
      return order;
    } catch (error) {
      console.error('Razorpay Create Order Error:', error);
      throw new Error('Failed to create payment order');
    }
  }

  /**
   * Verify Razorpay Payment Signature
   * @param {string} orderId - Razorpay Order ID
   * @param {string} paymentId - Razorpay Payment ID
   * @param {string} signature - Razorpay Signature
   * @returns {boolean}
   */
  verifySignature(orderId, paymentId, signature) {
    if (!this.razorpay) {
      throw new Error('Payment service is not configured');
    }
    const text = orderId + '|' + paymentId;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(text)
      .digest('hex');

    return expectedSignature === signature;
  }
}

module.exports = new PaymentService();
