const prisma = require('../models/prisma');

class BankController {
  /**
   * Add Bank Account
   */
  async addBankAccount(req, res) {
    const { userId } = req.user;
    const { bankName, accountNumber, ifsc, accountHolder } = req.body;

    if (!bankName || !accountNumber || !ifsc || !accountHolder) {
      return res.status(400).json({ 
        error: 'Validation failed', 
        message: 'All bank fields (Name, Account Number, IFSC, Holder) are required' 
      });
    }

    try {
      // Check if this is the first account for the user
      const count = await prisma.bankAccount.count({ where: { userId } });
      
      const bankAccount = await prisma.bankAccount.create({
        data: {
          userId,
          bankName: bankName.trim(),
          accountNumber: accountNumber.trim(),
          ifsc: ifsc.trim().toUpperCase(),
          accountHolder: accountHolder.trim(),
          isPrimary: count === 0 // Make primary if it's the first one
        }
      });

      res.status(201).json(bankAccount);
    } catch (error) {
      console.error('Add Bank Account Error Details:', error);
      res.status(500).json({ 
        error: 'Database Error', 
        message: error.message || 'Failed to add bank account' 
      });
    }
  }

  /**
   * Get All Bank Accounts
   */
  async getBankAccounts(req, res) {
    const { userId } = req.user;
    try {
      const bankAccounts = await prisma.bankAccount.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });
      res.json(bankAccounts);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch bank accounts' });
    }
  }

  /**
   * Delete Bank Account
   */
  async deleteBankAccount(req, res) {
    const { userId } = req.user;
    const { id } = req.params;

    try {
      const account = await prisma.bankAccount.findFirst({
        where: { id, userId }
      });

      if (!account) return res.status(404).json({ error: 'Bank account not found' });

      await prisma.bankAccount.delete({ where: { id } });
      
      // If deleted account was primary, make the next one primary if exists
      if (account.isPrimary) {
        const nextAccount = await prisma.bankAccount.findFirst({
          where: { userId }
        });
        if (nextAccount) {
          await prisma.bankAccount.update({
            where: { id: nextAccount.id },
            data: { isPrimary: true }
          });
        }
      }

      res.json({ message: 'Bank account deleted successfully' });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete bank account' });
    }
  }

  /**
   * Set Primary Bank Account
   */
  async setPrimaryAccount(req, res) {
    const { userId } = req.user;
    const { id } = req.params;

    try {
      // Unset current primary
      await prisma.bankAccount.updateMany({
        where: { userId, isPrimary: true },
        data: { isPrimary: false }
      });

      // Set new primary
      await prisma.bankAccount.update({
        where: { id, userId },
        data: { isPrimary: true }
      });

      res.json({ message: 'Primary bank account updated' });
    } catch (error) {
      res.status(500).json({ error: 'Failed to update primary bank account' });
    }
  }
}

module.exports = new BankController();
