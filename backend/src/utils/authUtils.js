const bcrypt = require('bcrypt');

/**
 * Validates a password based on specific rules:
 * - Minimum 8 characters
 * - At least one uppercase letter
 * - At least one lowercase letter
 * - At least one numeric digit
 * - At least one special character
 * 
 * @param {string} password 
 * @returns {boolean}
 */
const validatePassword = (password) => {
  if (!password || password.length < 8) return false;
  
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
  
  return hasUppercase && hasLowercase && hasNumber && hasSpecial;
};

/**
 * Hashes a password using bcrypt.
 * 
 * @param {string} password 
 * @returns {Promise<string>}
 */
const hashPassword = async (password) => {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

/**
 * Compares a plain text password with a hashed one.
 * 
 * @param {string} password 
 * @param {string} hash 
 * @returns {Promise<boolean>}
 */
const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

/**
 * Generates a unique referral code in the format SILVRA-XXXX.
 * 
 * @param {object} prisma 
 * @returns {Promise<string>}
 */
const generateReferralCode = async (prisma) => {
  let isUnique = false;
  let referralCode = '';
  
  while (!isUnique) {
    // Generate 4 random digits
    const randomDigits = Math.floor(1000 + Math.random() * 9000).toString();
    referralCode = `SILVRA-${randomDigits}`;
    
    // Check uniqueness in database
    const existing = await prisma.user.findUnique({
      where: { referralCode }
    });
    
    if (!existing) {
      isUnique = true;
    }
  }
  
  return referralCode;
};

module.exports = {
  validatePassword,
  hashPassword,
  comparePassword,
  generateReferralCode
};
