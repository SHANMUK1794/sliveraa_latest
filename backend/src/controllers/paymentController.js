const paymentService = require('../services/paymentService');
const priceService = require('../services/priceService');
const rewardService = require('../services/rewardService');
const notificationService = require('../services/notificationService');
const prisma = require('../models/prisma');
const { createOrderSchema, verifyPaymentSchema } = require('../utils/schemas');

class PaymentController {
  /**
   * Create Cashfree Order for Adding Balance or Buying Metal
   * Flutter payload: amount, assetType, grams, userId
   */
  async createOrder(req, res) {
    if (!paymentService.isAvailable) {
      return res.status(501).json({ error: 'Not Implemented', message: 'Payment service is not configured' });
    }
    try {
      const { userId } = req.user;
      
      const user = await prisma.user.findUnique({ where: { id: userId } });
      
      // Validate
      const validated = createOrderSchema.parse({
        ...req.body,
        userId
      });
      const { amount, assetType, grams } = validated;
      let finalAmount = amount;
      let weight = grams;

      // GST Implementation: Allotment is based on 97% of total amount (Post 3% GST)
      if (assetType && finalAmount) {
        const symbol = assetType === 'GOLD' ? 'XAU' : 'XAG';
        const pricePerGram = await priceService.getLivePrice(symbol);
        const baseAmount = finalAmount / 1.03; // Deduct 3% GST
        weight = baseAmount / pricePerGram;
      }

      const receipt = 'order_' + Date.now() + '_' + Math.floor(Math.random() * 1000);
      
      const customer = {
        id: `CUST_${userId}`,
        phone: user.phoneNumber || '9999999999',
        email: user.email || 'customer@silvra.in',
        name: user.name || 'Silvra User'
      };

      const order = await paymentService.createOrder(finalAmount, customer, 'INR', receipt);

      // Create transaction record in pending state
      const transaction = await prisma.transaction.create({
        data: {
          userId,
          amount: finalAmount,
          weight: weight || null,
          type: assetType ? 'BUY' : 'DEPOSIT',
          metalType: assetType || null,
          pgOrderId: order.order_id,
          status: 'PENDING'
        }
      });

      res.json({
        success: true,
        message: 'Order created',
        orderId: order.order_id,
        paymentSessionId: order.payment_session_id, // Cashfree requires this for Flutter SDK
        cashfreeEnvironment: process.env.CASHFREE_ENVIRONMENT || 'SANDBOX',
        amount: order.order_amount,
        currency: order.order_currency,
        transactionId: transaction.id
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ 
          error: 'Validation Error', 
          details: error.errors.map(e => e.message) 
        });
      }
      console.error('Create Order Error:', error);
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }

  /**
   * Verify Cashfree Payment (usually called after SDK completes)
   */
  async verifyPayment(req, res) {
    if (!paymentService.isAvailable) {
      return res.status(501).json({ error: 'Not Implemented', message: 'Payment service is not configured' });
    }
    try {
      // For Cashfree, the frontend doesn't get a signature directly like Razorpay.
      // The frontend SDK just returns order completion status.
      // We should verify by calling the Cashfree Order API.
      const { orderId } = req.body;
      
      if (!orderId) {
        return res.status(400).json({ error: 'Missing orderId' });
      }

      const orderInfo = await paymentService.getOrder(orderId);
      
      if (!orderInfo) {
        return res.status(404).json({ error: 'Order not found in Payment Gateway' });
      }

      if (orderInfo.order_status === 'PAID') {
        const result = await this._fulfillOrder(orderId, orderInfo.cf_order_id || orderId);
        if (!result.success) {
          // If already processed, it's fine, we just tell the client it's successful
          return res.json({ success: true, message: 'Payment verified' });
        }
        return res.json({ success: true, message: 'Payment verified and transaction completed' });
      } else {
        return res.status(400).json({ error: 'Payment not successful yet' });
      }
    } catch (error) {
      console.error('Verify Payment Request Error:', error);
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }

  /**
   * Internal Method to fulfill order
   */
  async _fulfillOrder(pg_order_id, pg_payment_id) {
    // Find and update transaction
    const transaction = await prisma.transaction.findUnique({
      where: { pgOrderId: pg_order_id },
    });

    if (!transaction || transaction.status !== 'PENDING') {
      return { success: false, message: 'Transaction not found or already processed' };
    }

    await prisma.$transaction(async (tx) => {
      // Update Transaction
      await tx.transaction.update({
        where: { id: transaction.id },
        data: {
          status: 'COMPLETED',
          pgPaymentId: String(pg_payment_id)
        }
      });

      const userId = transaction.userId;

      // Update User Balance
      if (transaction.type === 'DEPOSIT') {
        await tx.user.update({
          where: { id: userId },
          data: { walletBalance: { increment: transaction.amount } }
        });
        await notificationService.notify(userId, 'Deposit Successful', `₹${transaction.amount} has been added to your wallet.`, 'TRANSACTION');
      } else if (transaction.type === 'BUY') {
        if (transaction.metalType === 'GOLD') {
          await tx.user.update({
            where: { id: userId },
            data: { goldBalance: { increment: transaction.weight || 0 } }
          });
          await notificationService.notify(userId, 'Gold Purchased', `Congratulations! ${transaction.weight?.toFixed(4)}gm 24K Gold added to your vault.`, 'TRANSACTION');
        } else if (transaction.metalType === 'SILVER') {
          await tx.user.update({
            where: { id: userId },
            data: { silverBalance: { increment: transaction.weight || 0 } }
          });
          await notificationService.notify(userId, 'Silver Purchased', `Congratulations! ${transaction.weight?.toFixed(4)}gm Fine Silver added to your vault.`, 'TRANSACTION');
        }
        // Award Rewards
        await rewardService.creditPurchaseReward(userId, transaction.amount);

        // Activate SIP if this was the first payment
        if (transaction.savingsPlanId) {
          await tx.savingsPlan.update({
            where: { id: transaction.savingsPlanId },
            data: { status: 'ACTIVE' }
          });
          await notificationService.notify(userId, 'SIP Activated', `Your ${transaction.metalType} SIP plan has been successfully activated.`, 'SYSTEM');
        }
      }
    });

    return { success: true };
  }

  /**
   * Cashfree Webhook Handler
   */
  async webhookHandler(req, res) {
    try {
      const signature = req.headers['x-webhook-signature'];
      const timestamp = req.headers['x-webhook-timestamp'];
      const rawBody = req.rawBody; // Make sure rawBody middleware is configured in app.js
      
      if (!signature || !timestamp || !rawBody) {
        return res.status(400).send('Missing webhook headers or raw body');
      }

      const isValid = paymentService.verifyWebhookSignature(rawBody, signature, timestamp);
      
      if (!isValid) {
        return res.status(401).send('Invalid Webhook Signature');
      }
      
      const payload = req.body;
      const eventName = payload.type; // CASHFREE webhook type (e.g., PAYMENT_SUCCESS_WEBHOOK)
      
      if (eventName === 'PAYMENT_SUCCESS_WEBHOOK') {
        const paymentEntity = payload.data.payment;
        const orderEntity = payload.data.order;
        const pg_order_id = orderEntity.order_id;
        const pg_payment_id = paymentEntity.cf_payment_id;
        
        if (pg_order_id && pg_payment_id) {
           await this._fulfillOrder(pg_order_id, pg_payment_id);
        }
      }
      
      res.status(200).send('OK');
    } catch (error) {
      console.error('Webhook Error:', error);
      res.status(500).send('Webhook Internal Error');
    }
  }
}

module.exports = new PaymentController();
