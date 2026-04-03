const kycService = require('../services/kycService');
const prisma = require('../models/prisma');
const authUtils = require('../utils/authUtils');

class UserController {
  /**
   * Get User Profile
   */
  async getProfile(req, res) {
    const { userId } = req.user;
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { 
          kycDetails: true, 
          rewards: true,
          transactions: { take: 10, orderBy: { createdAt: 'desc' } } 
        }
      });

      if (!user) return res.status(404).json({ error: 'User not found' });

      // Calculate total points
      const auraPoints = user.rewards.reduce((sum, r) => sum + r.points, 0);
      
      res.json({ ...user, auraPoints });
    } catch (error) {
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  /**
   * Get Transaction History
   */
  async getTransactions(req, res) {
    const { userId } = req.user;
    try {
      const transactions = await prisma.transaction.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });
      res.json(transactions);
    } catch (error) {
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  /**
   * Update User Profile (Name/Email)
   */
  async updateProfile(req, res) {
    const { userId } = req.user;
    const { name, email } = req.body;
    try {
      const user = await prisma.user.update({
        where: { id: userId },
        data: {
          name: name || undefined,
          email: email || undefined
        }
      });
      res.json({ message: 'Profile updated', user });
    } catch (error) {
      res.status(500).json({ error: 'Failed to update profile' });
    }
  }

  /**
   * Initiate Aadhaar Verification
   */
  async initiateAadhaar(req, res) {
    const { userId } = req.user;
    const { idNumber } = req.body;
    if (!idNumber) return res.status(400).json({ error: 'Aadhaar number required' });

    try {
      const response = await kycService.verifyAadhaar(idNumber);
      // Store draft KYC details
      await prisma.kycDetail.upsert({
        where: { userId },
        update: {
          documentType: 'AADHAAR',
          documentNumber: idNumber,
          verificationId: response.data.client_id,
          status: 'PENDING'
        },
        create: {
          userId,
          documentType: 'AADHAAR',
          documentNumber: idNumber,
          verificationId: response.data.client_id,
          status: 'PENDING'
        }
      });

      res.json({ message: 'Aadhaar OTP sent', clientId: response.data.client_id });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  /**
   * Submit Aadhaar OTP
   */
  async submitAadhaarOtp(req, res) {
    const { userId } = req.user;
    const { clientId, otp } = req.body;
    if (!clientId || !otp) return res.status(400).json({ error: 'Client ID and OTP required' });

    try {
      const response = await kycService.submitAadhaarOtp(clientId, otp);
      
      // Update User and KYC status
      await prisma.$transaction([
        prisma.kycDetail.update({
          where: { userId },
          data: {
            status: 'VERIFIED',
            verifiedAt: new Date(),
            rawResponse: response
          }
        }),
        prisma.user.update({
          where: { id: userId },
          data: { kycStatus: 'VERIFIED' }
        })
      ]);

      res.json({ message: 'Aadhaar verified successfully', userDetails: response.data });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  /**
   * Update Password
   */
  async updatePassword(req, res) {
    const { userId } = req.user;
    const { password } = req.body;
    if (!password) return res.status(400).json({ error: 'Password required' });

    try {
      const hashedPassword = await authUtils.hashPassword(password);
      await prisma.user.update({
        where: { id: userId },
        data: { password: hashedPassword }
      });
      res.json({ success: true, message: 'Password updated successfully' });
    } catch (error) {
      console.error('Update Password Error:', error);
      res.status(500).json({ error: 'Failed to update password' });
    }
  }
}

module.exports = new UserController();
