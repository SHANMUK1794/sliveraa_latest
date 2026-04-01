const prisma = require('./src/models/prisma');
const rewardService = require('./src/services/rewardService');

async function testReferral() {
  console.log('--- Testing Referral Reward Logic ---');

  try {
    // 1. Create dummy referrer
    const referrer = await prisma.user.create({
      data: {
        phoneNumber: '9999999911',
        name: 'Referrer User',
        referralCode: 'TESTREF123',
        walletBalance: 0
      }
    });
    console.log('Created Referrer:', referrer.phoneNumber);

    // 2. Create dummy referee
    const referee = await prisma.user.create({
      data: {
        phoneNumber: '9999999922',
        name: 'Referee User',
        referredBy: referrer.id,
        walletBalance: 0
      }
    });
    console.log('Created Referee:', referee.phoneNumber);

    // 3. Trigger Reward logic
    console.log('Crediting rewards...');
    await rewardService.creditReferralReward(referrer.id, referee.id);

    // 4. Verify Rewards
    const referrerRewards = await prisma.reward.findMany({ where: { userId: referrer.id } });
    const refereeRewards = await prisma.reward.findMany({ where: { userId: referee.id } });

    console.log('Referrer Points:', referrerRewards.reduce((s, r) => s + r.points, 0));
    console.log('Referee Points:', refereeRewards.reduce((s, r) => s + r.points, 0));

    // 5. Test Redemption
    console.log('Redeeming 50 points for Referrer...');
    await rewardService.redeemPoints(referrer.id, 50);

    const updatedReferrer = await prisma.user.findUnique({ where: { id: referrer.id } });
    console.log('Referrer Wallet Balance after Redemption:', updatedReferrer.walletBalance);

    // Cleanup (optional)
    // await prisma.reward.deleteMany({ where: { userId: { in: [referrer.id, referee.id] } } });
    // await prisma.transaction.deleteMany({ where: { userId: referrer.id } });
    // await prisma.user.delete({ where: { id: referee.id } });
    // await prisma.user.delete({ where: { id: referrer.id } });

    console.log('Referral Test Passed!');
  } catch (error) {
    console.error('Test Failed:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testReferral();
