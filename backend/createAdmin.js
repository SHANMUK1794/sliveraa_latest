const prisma = require('./src/models/prisma');
const authUtils = require('./src/utils/authUtils');

async function createAdmin() {
  try {
    const hashedPassword = await authUtils.hashPassword('SilvraAdmin@2026!');
    
    await prisma.user.upsert({
      where: { email: 'admin@silvras.com' },
      update: {
        password: hashedPassword,
        role: 'ADMIN',
        phoneNumber: '+919999999999'
      },
      create: {
        email: 'admin@silvras.com',
        phoneNumber: '+919999999999',
        password: hashedPassword,
        name: 'Super Admin',
        role: 'ADMIN',
        kycStatus: 'VERIFIED'
      }
    });
    console.log('Admin account successfully secured!');
  } catch (error) {
    console.error('Failed to create admin:', error);
  }
}

createAdmin().then(() => process.exit(0));
