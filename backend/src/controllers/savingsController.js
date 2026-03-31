const prisma = require('../models/prisma');
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
      nextPaymentDate.setMonth(nextPaymentDate.getMonth() + 1);

      const plan = await prisma.savingsPlan.create({
        data: {
          userId,
          metalType: validated.metalType,
          amount: validated.amount,
          nextPaymentDate,
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
}

module.exports = new SavingsController();
