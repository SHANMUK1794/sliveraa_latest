const prisma = require('../models/prisma');

class AdminController {
  
  async getMetrics(req, res) {
    try {
      const totalUsers = await prisma.user.count();
      
      const balances = await prisma.user.aggregate({
        _sum: {
          walletBalance: true,
          goldBalance: true,
          silverBalance: true,
        }
      });
      
      const activeSips = await prisma.savingsPlan.count({
        where: { status: 'ACTIVE' }
      });
      
      const pendingDeliveries = await prisma.deliveryRequest.count({
        where: { status: 'PENDING' }
      });

      res.json({
        success: true,
        metrics: {
          totalUsers,
          totalWalletBalance: balances._sum.walletBalance || 0,
          totalGoldInVault: balances._sum.goldBalance || 0,
          totalSilverInVault: balances._sum.silverBalance || 0,
          activeSips,
          pendingDeliveries,
        }
      });
    } catch (error) {
      console.error('Admin Metrics Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async getUsers(req, res) {
    try {
      const users = await prisma.user.findMany({
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          phoneNumber: true,
          email: true,
          kycStatus: true,
          walletBalance: true,
          goldBalance: true,
          silverBalance: true,
          role: true,
          createdAt: true,
        }
      });
      res.json({ success: true, users });
    } catch (error) {
      console.error('Admin Get Users Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async getUserDetails(req, res) {
    try {
      const { id } = req.params;
      const user = await prisma.user.findUnique({
        where: { id },
        include: {
          rewards: true,
          bankAccounts: true,
          addresses: true,
          savingsPlans: true,
          kycDetails: true,
          transactions: { orderBy: { createdAt: 'desc' }, take: 10 }
        }
      });
      
      if (!user) return res.status(404).json({ success: false, message: 'User not found' });
      
      res.json({ success: true, user });
    } catch (error) {
      console.error('Admin Get User Details Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async getDeliveries(req, res) {
    try {
      const deliveries = await prisma.deliveryRequest.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { name: true, phoneNumber: true } },
          address: true
        }
      });
      res.json({ success: true, deliveries });
    } catch (error) {
      console.error('Admin Get Deliveries Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async updateDelivery(req, res) {
    try {
      const { id } = req.params;
      const { status, trackingId } = req.body;
      
      const delivery = await prisma.deliveryRequest.update({
        where: { id },
        data: {
          status,
          trackingId: trackingId || null,
        }
      });
      res.json({ success: true, message: 'Delivery updated successfully', delivery });
    } catch (error) {
      console.error('Admin Update Delivery Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async getTransactions(req, res) {
    try {
      const transactions = await prisma.transaction.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { name: true, phoneNumber: true } }
        }
      });
      res.json({ success: true, transactions });
    } catch (error) {
      console.error('Admin Get Transactions Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async getSips(req, res) {
    try {
      const sips = await prisma.savingsPlan.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { name: true, phoneNumber: true, walletBalance: true } }
        }
      });
      res.json({ success: true, sips });
    } catch (error) {
      console.error('Admin Get SIPs Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async processKyc(req, res) {
    try {
      const { id } = req.params; // this is the USER ID
      const { status } = req.body; // 'VERIFIED' or 'REJECTED'
      
      await prisma.$transaction(async (tx) => {
        await tx.kycDetail.updateMany({
          where: { userId: id },
          data: { status }
        });
        
        await tx.user.update({
          where: { id },
          data: { kycStatus: status }
        });
      });

      res.json({ success: true, message: `KYC status updated to ${status}` });
    } catch (error) {
      console.error('Admin Process KYC Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }
}

module.exports = new AdminController();
