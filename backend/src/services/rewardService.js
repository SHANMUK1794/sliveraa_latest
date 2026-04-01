const prisma = require('../models/prisma');

class RewardService {
  /**
   * Credit referral points to both users
   * @param {string} referrerId - The user who referred
   * @param {string} refereeId - The newly registered user
   */
  async creditReferralReward(referrerId, refereeId) {
    const REWARD_POINTS = 50; // ₹50 value (configurable)

    try {
      await prisma.$transaction([
        // 1. Credit Referrer
        prisma.reward.create({
          data: {
            userId: referrerId,
            points: REWARD_POINTS,
            description: 'Referral Bonus (New Signup)',
            type: 'REFERRAL'
          }
        }),
        // 2. Credit Referee (Optional but good UX)
        prisma.reward.create({
          data: {
            userId: refereeId,
            points: REWARD_POINTS,
            description: 'Welcome Bonus (Referred)',
            type: 'REFERRAL'
          }
        })
      ]);
      return true;
    } catch (error) {
      console.error('RewardService Error:', error.message);
      return false;
    }
  }

  /**
   * Redeem points into wallet balance
   * @param {string} userId
   * @param {number} points
   */
  async redeemPoints(userId, points) {
    const POINT_VALUE = 1; // 1 Point = ₹1

    try {
      const result = await prisma.$transaction(async (tx) => {
        // 1. Check current points
        const rewards = await tx.reward.findMany({ where: { userId } });
        const totalPoints = rewards.reduce((sum, r) => sum + r.points, 0);

        if (totalPoints < points) {
          throw new Error('Insufficient points to redeem');
        }

        // 2. Add to wallet balance
        const amountToCredit = points * POINT_VALUE;
        await tx.user.update({
          where: { id: userId },
          data: { walletBalance: { increment: amountToCredit } }
        });

        // 3. Record redemption (negative reward to balance things out?)
        // Or create a special 'REDEEMED' reward record
        await tx.reward.create({
          data: {
            userId,
            points: -points,
            description: `Redeemed points to wallet balance (₹${amountToCredit})`,
            type: 'REDEMPTION'
          }
        });

        // 4. Log as a transaction
        await tx.transaction.create({
          data: {
            userId,
            type: 'REWARD',
            amount: amountToCredit,
            status: 'COMPLETED'
          }
        });

        return amountToCredit;
      });
      return result;
    } catch (error) {
      console.error('Redemption Error:', error.message);
      throw error;
    }
  }
}

module.exports = new RewardService();
