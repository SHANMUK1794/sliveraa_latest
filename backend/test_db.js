const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
require('dotenv').config();

async function main() {
  console.log('--- DATABASE CONNECTION TESTER ---');
  console.log('Using DATABASE_URL:', process.env.DATABASE_URL ? (process.env.DATABASE_URL.slice(0, 20) + '...') : 'NOT SET');
  
  try {
    console.log('1. Attempting to connect to the database...');
    await prisma.$connect();
    console.log('✅ Connection successful!');

    console.log('2. Running simple query...');
    const result = await prisma.$queryRaw`SELECT 1 as connected`;
    console.log('✅ Query successful:', result);

    console.log('3. Checking for User table...');
    const users = await prisma.user.count();
    console.log('✅ User table exists. Count:', users);

    console.log('4. Checking for BankAccount table...');
    try {
      const bankAccounts = await prisma.bankAccount.count();
      console.log('✅ BankAccount table exists. Count:', bankAccounts);
    } catch (e) {
      console.error('❌ BankAccount table is missing!');
      console.error('   Details:', e.message);
      console.error('   FIX: Run "npx prisma db push" to create it.');
    }

  } catch (error) {
    console.error('❌ FATAL ERROR: Database connection failed!');
    console.error('   Code:', error.code || 'UNKNOWN');
    console.error('   Message:', error.message);
    
    if (error.message.includes('P1001')) {
      console.error('\nSUGGESTION: The server is unreachable. Check your Railway public proxy settings.');
    } else if (error.message.includes('P1017')) {
      console.error('\nSUGGESTION: Invalid credentials. Check your username/password.');
    }
  } finally {
    await prisma.$disconnect();
    console.log('---------------------------------');
  }
}

main();
