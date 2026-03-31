const authUtils = require('./backend/src/utils/authUtils');

const testPasswords = [
  { pass: 'short', expected: false, reason: 'Too short' },
  { pass: 'onlylowercase', expected: false, reason: 'No uppercase/numeric/special' },
  { pass: 'OnlyLetters', expected: false, reason: 'No numeric/special' },
  { pass: 'Letters123', expected: false, reason: 'No special' },
  { pass: 'Lett123!', expected: true, reason: 'Valid (8 chars, mixed case, num, spec)' },
  { pass: 'STrongPass-1234', expected: true, reason: 'Valid' },
  { pass: 'noUPPERCASE1!', expected: false, reason: 'No uppercase' },
  { pass: 'NOLOWERCASE1!', expected: false, reason: 'No lowercase' }
];

async function runTests() {
  console.log('--- Password Validation Tests ---');
  for (const t of testPasswords) {
    const result = authUtils.validatePassword(t.pass);
    console.log(`Password: ${t.pass.padEnd(15)} | Expected: ${t.expected} | Result: ${result} | ${result === t.expected ? '✅' : '❌'}`);
  }

  console.log('\n--- Password Hashing Tests ---');
  const pass = 'STrongPass-1234';
  const hashed = await authUtils.hashPassword(pass);
  console.log(`Plain: ${pass}`);
  console.log(`Hashed: ${hashed}`);
  
  const isMatch = await authUtils.comparePassword(pass, hashed);
  console.log(`Match Result: ${isMatch ? '✅ MATCH' : '❌ FAIL'}`);
  
  const isMatchWrong = await authUtils.comparePassword('wrongpassword', hashed);
  console.log(`Wrong Password Match: ${isMatchWrong ? '❌ FAIL (matches)' : '✅ PASS (no match)'}`);
}

runTests().catch(console.error);
