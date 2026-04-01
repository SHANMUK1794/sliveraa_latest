const prisma = require('../models/prisma');
const priceService = require('../services/priceService');
const { savingsPlanSchema } = require('../utils/schemas');

class SavingsController {
  /**
   * Create New Savings Plan (SIP)
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
        return res.status(400).json({ error: 'Duplicate Plan', message: `You already have an active SIP for ${validated.metalType}` });
      }

      const nextPaymentDate = new Date();
      // nextPaymentDate.setMonth(nextPaymentDate.getMonth() + 1);

      const plan = await prisma.savingsPlan.create({
        data: {
          userId,
          metalType: validated.metalType,
          amount: validated.amount,
          nextPaymentDate, // Set to now for immediate first execution, or +1 month
          status: 'ACTIVE'
        }
      });

      res.status(201).json({ success: true, message: 'Savings plan started', plan });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
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
   * Process all due SIP payments
   * Triggered by cron job or manual test endpoint
   */
  async processDuePayments(req, res) {
    try {
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

          // 3. Execute transactional update
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
                nextPaymentDate: new Date(now.setMonth(now.getMonth() + 1))
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

      res.json({ success: true, message: 'SIP processing complete', results });
    } catch (error) {
      console.error('SIP Critical Error:', error.message);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }
}

module.exports = new SavingsController();
