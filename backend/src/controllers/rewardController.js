const prisma = require('../models/prisma');

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
   * Placeholder for adding referral rewards
   */
  async addReferralReward(req, res) {
    // Logic to credit referral points
    res.json({ success: true, message: 'Referral reward feature coming soon' });
  }
}

module.exports = new RewardController();
