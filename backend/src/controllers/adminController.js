const prisma = require('../models/prisma');

class AdminController {
  
  async getMetrics(req, res) {
    try {
      const { period } = req.query;
      let dateFilter = {};
      
      if (period && period !== 'all_time') {
        const now = new Date();
        const gteDate = new Date();
        if (period === 'daily') gteDate.setDate(now.getDate() - 1);
        else if (period === 'weekly') gteDate.setDate(now.getDate() - 7);
        else if (period === 'monthly') gteDate.setMonth(now.getMonth() - 1);
        
        dateFilter = {
          createdAt: {
            gte: gteDate
          }
        };
      }

      const totalUsers = await prisma.user.count({ where: dateFilter });
      
      // If we are filtering by period, we must get the aggregate of funds added IN that period! 
      // User balances just show the total *current* balance, they aren't timeframe-specific.
      // But let's assume we want total balances of users who JOINED in that timeframe, OR we can just return total system balances if the filter only applies to joined users.
      // The user requested: "memnber joind like that etc". It's easiest to apply dateFilter to the user row completely.
      const balances = await prisma.user.aggregate({
        where: dateFilter,
        _sum: {
          walletBalance: true,
          goldBalance: true,
          silverBalance: true,
        }
      });
      
      const activeSips = await prisma.savingsPlan.count({
        where: { status: 'ACTIVE', ...dateFilter }
      });
      
      const pendingDeliveries = await prisma.deliveryRequest.count({
        where: { status: 'PENDING', ...dateFilter }
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
      const { period } = req.query;
      let dateFilter = {};
      
      if (period && period !== 'all_time') {
        const now = new Date();
        const gteDate = new Date();
        if (period === 'daily') gteDate.setDate(now.getDate() - 1);
        else if (period === 'weekly') gteDate.setDate(now.getDate() - 7);
        else if (period === 'monthly') gteDate.setMonth(now.getMonth() - 1);
        
        dateFilter = {
          createdAt: {
            gte: gteDate
          }
        };
      }

      const users = await prisma.user.findMany({
        where: dateFilter,
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

  async updateUserRole(req, res) {
    try {
      const { id } = req.params;
      const { role } = req.body;
      
      const validRoles = ['USER', 'ADMIN', 'SUPER_ADMIN'];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ success: false, message: 'Invalid role specified' });
      }

      await prisma.user.update({
        where: { id },
        data: { role }
      });
      res.json({ success: true, message: `User role updated to ${role}` });
    } catch (error) {
      console.error('Super Admin Update Role Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }

  async createUser(req, res) {
    try {
      const { name, phoneNumber, email, password, role } = req.body;
      const authUtils = require('../utils/authUtils');
      
      const existingUser = await prisma.user.findFirst({
        where: {
          OR: [
            { phoneNumber },
            { email }
          ]
        }
      });

      if (existingUser) {
        return res.status(400).json({ success: false, message: 'A user with this phone number or email already exists' });
      }

      const validRoles = ['USER', 'ADMIN', 'SUPER_ADMIN'];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ success: false, message: 'Invalid role specified' });
      }

      const hashedPassword = password ? await authUtils.hashPassword(password) : null;
      const referralCode = await authUtils.generateReferralCode(prisma);

      const user = await prisma.user.create({
        data: {
          name,
          phoneNumber,
          email: email ? email.toLowerCase() : null,
          password: hashedPassword,
          role,
          referralCode
        }
      });
      
      res.json({ success: true, message: `User created successfully with role ${role}` });
    } catch (error) {
      console.error('Super Admin Create User Error:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
  }
}

module.exports = new AdminController();
