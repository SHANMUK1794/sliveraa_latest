const kycService = require('./src/services/kycService');
const kycController = require('./src/controllers/kycController');

// Mock req/res
const mockUser = { id: 'test-user-id' };
const mockRes = {
  status: function(code) { this.statusCode = code; return this; },
  json: function(data) { this.data = data; return this; }
};

async function testUserPan() {
  console.log('--- Testing PAN Verification Logic ---');
  
  const panNumber = 'DEIPC5387F';
  const fullName = 'POLAVARAPU VENKATA SHANMUKA CHOWDARY';
  const dob = '2006-05-09'; // Normalized from 09-05-2006

  console.log(`Input PAN: ${panNumber}`);
  console.log(`Input Name: ${fullName}`);
  console.log(`Input DOB: ${dob}`);

  // 1. Test Name Matching Logic (Simulated)
  const officialNameFromApi = 'POLAVARAPU VENKATA SHANMUKA CHOWDARY'; // Example from PAN
  const officialDobFromApi = '2006-05-09';

  const normalizedInputName = fullName.toLowerCase().trim();
  const normalizedOfficialName = officialNameFromApi.toLowerCase().trim();

  const isNameMatch = normalizedOfficialName.includes(normalizedInputName) || normalizedInputName.includes(normalizedOfficialName);
  const isDobMatch = officialDobFromApi === dob;

  console.log(`\nMatching Results (Simulated):`);
  console.log(`Name Match: ${isNameMatch ? '✅' : '❌'}`);
  console.log(`DOB Match: ${isDobMatch ? '✅' : '❌'}`);

  if (isNameMatch && isDobMatch) {
    console.log('\nResult: Verification would SUCCEED');
  } else {
    console.log('\nResult: Verification would FAIL');
  }
}

testUserPan().catch(console.error);
