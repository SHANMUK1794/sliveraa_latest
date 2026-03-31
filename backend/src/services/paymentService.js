const Razorpay = require('razorpay');
const crypto = require('crypto');

class PaymentService {
  constructor() {
    this.razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }

  /**
   * Create Razorpay Order
   * @param {number} amount - Amount in paise (e.g., 10000 for 100 INR)
   * @param {string} currency - currency (default INR)
   * @param {string} receipt - receipt id
   * @returns {Promise<any>}
   */
  async createOrder(amount, currency = 'INR', receipt = 'receipt_' + Date.now()) {
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
    const text = orderId + '|' + paymentId;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(text)
      .digest('hex');

    return expectedSignature === signature;
  }
}

module.exports = new PaymentService();
