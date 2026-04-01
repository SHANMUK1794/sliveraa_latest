const prisma = require('./src/models/prisma');
const savingsController = require('./src/controllers/savingsController');

async function testSip() {
  console.log('--- Testing SIP (Savings) Logic ---');

  try {
    // 1. Create dummy user with wallet balance
    const user = await prisma.user.create({
      data: {
        phoneNumber: '9988776655',
        name: 'SIP Test User',
        walletBalance: 2000,
        goldBalance: 0
      }
    });

    // 2. Create an ACTIVE SIP plan due TODAY
    const plan = await prisma.savingsPlan.create({
      data: {
        userId: user.id,
        metalType: 'GOLD',
        amount: 1000,
        nextPaymentDate: new Date(), // Due now
        status: 'ACTIVE'
      }
    });

    console.log('Created User with ₹2000 and SIP for ₹1000');

    // 3. Process Dues
    console.log('Processing SIPs...');
    await savingsController.processDuePayments({}, { json: (data) => console.log('SIP Result:', data) });

    // 4. Verify user balance
    const updatedUser = await prisma.user.findUnique({ where: { id: user.id } });
    const updatedPlan = await prisma.savingsPlan.findUnique({ where: { id: plan.id } });

    console.log('User Wallet after SIP:', updatedUser.walletBalance);
    console.log('User Gold Balance after SIP:', updatedUser.goldBalance);
    console.log('Next SIP Date:', updatedPlan.nextPaymentDate);

    if (updatedUser.walletBalance === 1000 && updatedUser.goldBalance > 0) {
      console.log('SIP Logic Passed!');
    } else {
      console.log('SIP Logic Validation Failed.');
    }

  } catch (error) {
    console.error('Test Failed:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testSip();
