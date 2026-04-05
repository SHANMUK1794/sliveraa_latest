const prisma = require('../models/prisma');
const priceService = require('../services/priceService');
const paymentService = require('../services/paymentService');
const { savingsPlanSchema } = require('../utils/schemas');

class SavingsController {
  /**
   * Create New Savings Plan (SIP)
   * This creates a PENDING plan and returns a Razorpay Order for the first installment.
   */
  async createPlan(req, res) {
    try {
      const { userId } = req.user;
      const validated = savingsPlanSchema.parse(req.body);

      // Check for existing active plan of same metal
      const existing = await prisma.savingsPlan.findFirst({
        where: { userId, metalType: validated.metalType, status: 'ACTIVE' }
      });

      if (existing) {
        return res.status(400).json({ 
          error: 'Duplicate Plan', 
          message: `You already have an active SIP for ${validated.metalType}` 
        });
      }

      // 1. Create the Plan in PENDING state
      // First installment is immediate, so next installment is based on frequency
      const nextPaymentDate = new Date();
      if (validated.frequency === 'DAILY') {
        nextPaymentDate.setDate(nextPaymentDate.getDate() + 1);
      } else if (validated.frequency === 'WEEKLY') {
        nextPaymentDate.setDate(nextPaymentDate.getDate() + 7);
      } else {
        nextPaymentDate.setMonth(nextPaymentDate.getMonth() + 1);
      }

      const plan = await prisma.savingsPlan.create({
        data: {
          userId,
          metalType: validated.metalType,
          amount: validated.amount,
          frequency: validated.frequency,
          nextPaymentDate,
          status: 'PENDING'
        }
      });

      // 2. Create Razorpay Order for the first installment
      const symbol = validated.metalType === 'GOLD' ? 'XAU' : 'XAG';
      const pricePerGram = await priceService.getLivePrice(symbol);
      const amountPaise = Math.round(validated.amount * 100);
      const baseAmount = validated.amount / 1.03; // Deduct 3% GST
      const weight = baseAmount / pricePerGram;

      const order = await paymentService.createOrder(amountPaise);

      // 3. Create a PENDING transaction linked to this plan
      await prisma.transaction.create({
        data: {
          userId,
          amount: validated.amount,
          weight: weight,
          type: 'BUY',
          metalType: validated.metalType,
          razorpayOrderId: order.id,
          savingsPlanId: plan.id, // CRITICAL: This links the payment to activation
          status: 'PENDING'
        }
      });

      res.status(201).json({ 
        success: true, 
        message: 'SIP Plan initiated. Complete payment to activate.', 
        orderId: order.id,
        razorpayKeyId: process.env.RAZORPAY_KEY_ID, // Return this for the frontend
        planId: plan.id,
        amount: validated.amount
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      console.error('Create SIP Plan Error:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Get User Plans
   */
  async getPlans(req, res) {
    try {
      const { userId } = req.user;
      const plans = await prisma.savingsPlan.findMany({
        where: { userId }
      });
      res.json({ success: true, plans });
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Internal Method to Process Dues
   * Can be called by Cron Job or API
   */
  async _processDuesInternal() {
    const now = new Date();
    const duePlans = await prisma.savingsPlan.findMany({
      where: {
        status: 'ACTIVE',
        nextPaymentDate: { lte: now }
      },
      include: { user: true }
    });

    const results = { successful: 0, failed: 0, details: [] };

    for (const plan of duePlans) {
      try {
        // 1. Check if user has sufficient wallet balance
        if (plan.user.walletBalance < plan.amount) {
          throw new Error(`Insufficient wallet balance (UserId: ${plan.userId})`);
        }

        // 2. Get current price
        const symbol = plan.metalType === 'GOLD' ? 'XAU' : 'XAG';
        const pricePerOunce = await priceService.getLivePrice(symbol);
        const pricePerGram = pricePerOunce / 31.1034768;
        const gramsToBuy = plan.amount / pricePerGram;

        // 3. Calculate next payment date based on frequency
        const nextDate = new Date(plan.nextPaymentDate);
        if (plan.frequency === 'DAILY') {
          nextDate.setDate(nextDate.getDate() + 1);
        } else if (plan.frequency === 'WEEKLY') {
          nextDate.setDate(nextDate.getDate() + 7);
        } else {
          nextDate.setMonth(nextDate.getMonth() + 1);
        }

        // 4. Execute transactional update
        await prisma.$transaction([
          // Deduct from wallet
          prisma.user.update({
            where: { id: plan.userId },
            data: {
              walletBalance: { decrement: plan.amount },
              [plan.metalType === 'GOLD' ? 'goldBalance' : 'silverBalance']: { increment: gramsToBuy }
            }
          }),
          // Update plan schedule
          prisma.savingsPlan.update({
            where: { id: plan.id },
            data: {
              nextPaymentDate: nextDate
            }
          }),
          // Log Transaction
          prisma.transaction.create({
            data: {
              userId: plan.userId,
              type: 'BUY',
              metalType: plan.metalType,
              amount: plan.amount,
              weight: gramsToBuy,
              pricePerUnit: pricePerGram,
              status: 'COMPLETED'
            }
          })
        ]);

        results.successful++;
        results.details.push({ planId: plan.id, status: 'SUCCESS' });
      } catch (planError) {
        console.error(`SIP Process Failure Code [${plan.id}]:`, planError.message);
        results.failed++;
        results.details.push({ planId: plan.id, status: 'FAILED', reason: planError.message });
      }
    }
    return results;
  }

  /**
   * Process all due SIP payments (API Wrapper)
   */
  async processDuePayments(req, res) {
    try {
      const results = await this._processDuesInternal();
      res.json({ success: true, message: 'SIP processing complete', results });
    } catch (error) {
      console.error('SIP Critical Error:', error.message);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }
}

module.exports = new SavingsController();
