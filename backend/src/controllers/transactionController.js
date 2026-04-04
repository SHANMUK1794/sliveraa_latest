const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const priceService = require('../services/priceService');

class TransactionController {
  /**
   * Withdraw funds (Sell Metal)
   */
  async withdraw(req, res) {
    try {
      const { amount, metalType } = req.body; // amount is in INR
      const userId = req.user.id; // From authMiddleware

      if (!amount || amount < 100) {
        return res.status(400).json({ error: 'Minimum withdrawal amount is ₹100' });
      }

      if (!['GOLD', 'SILVER'].includes(metalType)) {
        return res.status(400).json({ error: 'Invalid metal type' });
      }

      const symbol = metalType === 'GOLD' ? 'XAU' : 'XAG';
      const livePrice = await priceService.getLivePrice(symbol);
      
      if (!livePrice) {
        return res.status(500).json({ error: 'Could not fetch live price' });
      }

      const weightToDeduct = amount / livePrice;

      // Check user balance
      const user = await prisma.user.findUnique({ where: { id: userId } });
      
      const currentBalance = metalType === 'GOLD' ? user.goldBalance : user.silverBalance;
      
      if (currentBalance < weightToDeduct) {
        return res.status(400).json({ error: 'Insufficient metal balance' });
      }

      // Perform transaction in a PRISMA transaction
      const transaction = await prisma.$transaction(async (tx) => {
        // 1. Deduct metal balance
        const updatedUser = await tx.user.update({
          where: { id: userId },
          data: {
            [metalType === 'GOLD' ? 'goldBalance' : 'silverBalance']: { decrement: weightToDeduct }
          }
        });

        // 2. Create transaction record
        const transRecord = await tx.transaction.create({
          data: {
            userId,
            type: 'WITHDRAWAL',
            metalType,
            amount,
            weight: weightToDeduct,
            pricePerUnit: livePrice,
            status: 'COMPLETED'
          }
        });

        return { transRecord, newBalance: metalType === 'GOLD' ? updatedUser.goldBalance : updatedUser.silverBalance };
      });

      res.json({
        message: 'Withdrawal successful',
        transaction: transaction.transRecord,
        newBalance: transaction.newBalance,
        weightDeducted: weightToDeduct
      });

    } catch (error) {
      console.error('Withdrawal Error:', error);
      res.status(500).json({ error: 'Failed to process withdrawal' });
    }
  }

  /**
   * Get user transactions
   */
  async getTransactions(req, res) {
    try {
      const userId = req.user.id;
      const transactions = await prisma.transaction.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 50
      });
      res.json(transactions);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch transactions' });
    }
  }
}

module.exports = new TransactionController();
