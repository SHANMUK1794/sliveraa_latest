const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/auth';

async function test() {
  console.log('🚀 Starting Auth Feature Tests...\n');

  // Test 1: Register with weak password
  try {
    console.log('Test 1: Register with weak password...');
    const res1 = await axios.post(`${BASE_URL}/verify-otp`, {
      phone: '910000000001',
      otp: '123456',
      name: 'Test User 1',
      email: 'test1@example.com',
      intent: 'register',
      password: 'weak'
    });
    console.log('❌ FAIL: Weak password accepted unexpectedly', res1.data);
  } catch (err) {
    console.log('✅ PASS: Weak password rejected correctly:', err.response?.data?.error || err.message);
  }

  // Test 2: Register with strong password
  let user;
  try {
    console.log('\nTest 2: Register with strong password...');
    const res2 = await axios.post(`${BASE_URL}/verify-otp`, {
      phone: '910000000001',
      otp: '123456',
      name: 'Test User 1',
      email: 'test1@example.com',
      intent: 'register',
      password: 'StrongPass123!'
    });
    user = res2.data.user;
    console.log('✅ PASS: Registration successful');
  } catch (err) {
    console.log('❌ FAIL: Registration failed:', err.response?.data?.error || err.message);
  }

  // Test 3: Duplicate Registration
  try {
    console.log('\nTest 3: Duplicate registration (same phone)...');
    await axios.post(`${BASE_URL}/verify-otp`, {
      phone: '910000000001',
      otp: '123456',
      intent: 'register',
      password: 'StrongPass123!'
    });
    console.log('❌ FAIL: Duplicate phone number accepted');
  } catch (err) {
    console.log('✅ PASS: Duplicate phone number blocked correctly:', err.response?.data?.error || err.message);
  }

  // Test 4: Password Login
  try {
    console.log('\nTest 4: Password login...');
    const res4 = await axios.post(`${BASE_URL}/login`, {
      phone: '910000000001',
      password: 'StrongPass123!'
    });
    console.log('✅ PASS: Login successful. Token received:', !!res4.data.token);
  } catch (err) {
    console.log('❌ FAIL: Login failed:', err.response?.data?.error || err.message);
  }

  console.log('\n🏁 Tests Completed.');
}

test().catch(console.error);
