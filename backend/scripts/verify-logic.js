require('dotenv').config();
process.env.RAZORPAY_KEY_ID = 'rzp_test_MOCK_KEY'; // Force Mock Mode

const paymentService = require('../src/services/paymentService');
const rewardService = require('../src/services/rewardService');
const notificationService = require('../src/services/notificationService');
const prisma = require('../src/models/prisma');

async function test() {
  console.log('--- Testing Silvra Functional Logic ---');

  // 1. Test Mock Order
  const order = await paymentService.createOrder(100000); // ₹1000
  if (order.id.startsWith('order_mock_')) {
    console.log('✅ Mock Order Created:', order.id);
  } else {
    console.error('❌ Mock Order Failed');
  }

  // 2. Test Rewards
  // Find a test user or create one
  const user = await prisma.user.findFirst();
  if (user) {
    console.log('Found user:', user.phoneNumber);
    
    console.log('Testing Reward Credit...');
    const reward = await rewardService.creditPurchaseReward(user.id, 1000);
    if (reward && reward.points === 50) {
      console.log('✅ 5% Reward Points Credited:', reward.points);
    } else {
      console.error('❌ Reward Credit Failed');
    }

    console.log('Testing Notification...');
    const note = await notificationService.notify(user.id, 'Test Alert', 'Logic is working', 'SYSTEM');
    if (note) {
      console.log('✅ Notification Created:', note.title);
    } else {
      console.error('❌ Notification Failed');
    }
  } else {
    console.log('No user found to test rewards/notifications. Please register a user first.');
  }

  console.log('--- Logic Verification Complete ---');
  process.exit(0);
}

test().catch(err => {
  console.error(err);
  process.exit(1);
});
