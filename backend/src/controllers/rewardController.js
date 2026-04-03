const prisma = require('../models/prisma');
const rewardService = require('../services/rewardService');

class RewardController {
  /**
   * Get User Rewards and Total Points
   */
  async getRewards(req, res) {
    try {
      const { userId } = req.user;
      
      const rewards = await prisma.reward.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });

      const totalPoints = rewards.reduce((sum, r) => sum + r.points, 0);

      res.json({
        success: true,
        totalPoints,
        rewards
      });
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Add referral reward for both referrer and referee
   */
  async addReferralReward(req, res) {
    try {
      const { referrerId, refereeId } = req.body;

      if (!referrerId || !refereeId) {
        return res.status(400).json({
          error: 'Invalid input',
          message: 'referrerId and refereeId are required'
        });
      }

      if (referrerId === refereeId) {
        return res.status(400).json({
          error: 'Invalid input',
          message: 'referrerId and refereeId must be different users'
        });
      }

      const success = await rewardService.creditReferralReward(referrerId, refereeId);

      if (!success) {
        return res.status(500).json({ error: 'Failed to credit referral reward' });
      }

      const rewards = await prisma.reward.findMany({
        where: {
          userId: { in: [referrerId, refereeId] },
          type: 'REFERRAL'
        },
        orderBy: { createdAt: 'desc' },
        take: 2
      });

      res.status(201).json({
        success: true,
        message: 'Referral reward credited successfully',
        rewards
      });
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Redeem points into wallet balance
   */
  async redeemPoints(req, res) {
    try {
      const { userId } = req.user;
      const { points } = req.body;

      if (!points || points <= 0) {
        return res.status(400).json({ error: 'Invalid input', message: 'Points must be greater than zero' });
      }

      const amountCredited = await rewardService.redeemPoints(userId, points);

      res.json({ 
        success: true, 
        message: `Successfully redeemed ${points} points for ₹${amountCredited}`,
        amountCredited 
      });
    } catch (error) {
      res.status(400).json({ error: 'Redemption failed', message: error.message });
    }
  }

  /**
   * Claim a spin wheel reward
   */
  async claimSpinReward(req, res) {
    try {
      const { userId } = req.user;
      const { wonItem } = req.body;

      if (!wonItem) {
        return res.status(400).json({ error: 'Input required', message: 'wonItem is required' });
      }

      const result = await rewardService.creditSpinReward(userId, wonItem.toString());

      res.status(201).json({
        success: true,
        message: 'Reward claimed successfully',
        data: result
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to claim reward', message: error.message });
    }
  }
}

module.exports = new RewardController();
