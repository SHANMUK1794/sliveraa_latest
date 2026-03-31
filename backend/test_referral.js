const { generateReferralCode } = require('./src/utils/authUtils');

// Mock Prisma
const prisma = {
  user: {
    findUnique: async ({ where }) => {
      console.log(`Checking uniqueness for: ${where.referralCode}`);
      return null; // Mock as unique
    }
  }
};

(async () => {
  for (let i = 0; i < 5; i++) {
    const code = await generateReferralCode(prisma);
    console.log(`Generated Code ${i+1}: ${code}`);
    if (!/^SILVRA-[0-9]{4}$/.test(code)) {
      console.error('FAILED: Invalid format');
      process.exit(1);
    }
  }
  console.log('ALL TESTS PASSED: Referral codes are correctly formatted.');
})();
