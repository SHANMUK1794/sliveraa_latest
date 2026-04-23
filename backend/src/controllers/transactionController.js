const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const priceService = require('../services/priceService');
const notificationService = require('../services/notificationService');
const payoutService = require('../services/payoutService');

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

      // Check user balance and Bank Account
      const user = await prisma.user.findUnique({ 
        where: { id: userId },
        include: { bankAccounts: true }
      });
      
      const currentBalance = metalType === 'GOLD' ? user.goldBalance : user.silverBalance;
      
      if (currentBalance < weightToDeduct) {
        return res.status(400).json({ error: 'Insufficient metal balance' });
      }

      const primaryBank = user.bankAccounts.find(b => b.isPrimary) || user.bankAccounts[0];
      if (!primaryBank) {
        return res.status(400).json({ error: 'No bank account added. Please add a bank account first.' });
      }

      // Initiate Payout with Cashfree
      const beneId = `BENE_${userId}_${primaryBank.id.substring(0,8)}`;
      let payoutTransfer;
      
      if (payoutService.isAvailable) {
        try {
          const token = await payoutService.authenticate();
          
          // Add Beneficiary if not exists
          await payoutService.addBeneficiary(token, {
            id: beneId,
            name: primaryBank.accountHolder,
            phone: user.phoneNumber,
            email: user.email,
            accountNumber: primaryBank.accountNumber,
            ifsc: primaryBank.ifsc
          });

          // Request Transfer
          const transferId = `TRF_${Date.now()}`;
          payoutTransfer = await payoutService.requestTransfer(amount, transferId, beneId);
          
        } catch (payoutError) {
          console.error('Payout Failed:', payoutError.message);
          return res.status(500).json({ error: 'Failed to initiate payout. Try again later.' });
        }
      } else {
        console.warn('Payout Service not configured. Simulating payout...');
        payoutTransfer = { referenceId: 'SIMULATED_TRF' };
      }

      // Perform transaction in a PRISMA transaction
      const transactionResult = await prisma.$transaction(async (tx) => {
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
            status: 'COMPLETED',
            pgOrderId: payoutTransfer?.referenceId || null
          }
        });

        await notificationService.notify(userId, 'Withdrawal Processed', `₹${amount} has been debited from your ${metalType} balance and transferred to your bank.`, 'TRANSACTION');

        return { newBalance: metalType === 'GOLD' ? updatedUser.goldBalance : updatedUser.silverBalance, transRecord };
      });

      res.json({
        message: 'Withdrawal successful',
        transaction: transactionResult.transRecord,
        newBalance: transactionResult.newBalance,
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
