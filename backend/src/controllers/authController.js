const otpService = require('../services/otpService');
const jwt = require('jsonwebtoken');
const prisma = require('../models/prisma');
const authUtils = require('../utils/authUtils');
const { registerSchema, loginSchema, sendOtpSchema, verifyOtpSchema } = require('../utils/schemas');

class AuthController {
  /**
   * Send OTP (Flutter uses 'phone' field)
   */
  async sendOtp(req, res) {
    if (!otpService.isAvailable) {
      return res.status(501).json({ error: 'Not Implemented', message: 'OTP service is not configured' });
    }
    try {
      const validated = sendOtpSchema.parse(req.body);
      const { phone, intent, email } = validated;

      // Duplicate Check (Early UX optimization)
      if (intent === 'register') {
        const user = await prisma.user.findUnique({ where: { phoneNumber: phone } });
        if (user) {
          return res.status(400).json({ error: 'Account exists', message: 'An account with this phone number already exists' });
        }
        if (email) {
          const emailCheck = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
          if (emailCheck) {
            return res.status(400).json({ error: 'Email exists', message: 'An account with this email address already exists' });
          }
        }
      } else if (intent === 'login' || intent === 'reset-password') {
        const user = await prisma.user.findUnique({ where: { phoneNumber: phone } });
        if (!user) {
          return res.status(404).json({ 
            error: 'Not found', 
            message: 'No account found with this phone number. Please register first.' 
          });
        }
      }

      // 1. Generate 6-digit code
      const code = Math.floor(100000 + Math.random() * 900000).toString();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

      // 2. Store in DB (Upsert to avoid multiple active OTPs for same intent)
      await prisma.otpVerification.create({
        data: {
          phoneNumber: phone,
          code,
          intent,
          expiresAt
        }
      });

      // 3. Send via MSG91 Flow API
      try {
        await otpService.sendOtp(phone, code);
      } catch (smsError) {
        console.error('SMS Delivery Failure:', smsError);
        // We continue anyway so the user can at least try to verify if they have the code
        // OR we can return an error if we want it to be strict.
      }

      res.status(200).json({ success: true, message: 'OTP sent successfully' });
    } catch (error) {
      if (error.name === 'ZodError' || error.issues) {
        const details = (error.errors || error.issues || []).map(e => e.message);
        return res.status(400).json({ error: 'Validation failed', details });
      }
      console.error('Send OTP Critical Error:', error);
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }

  /**
   * Verify OTP (Check DB)
   */
  async verifyOtp(req, res) {
    try {
      // Validate
      const validated = verifyOtpSchema.parse(req.body);
      const { phone, code, intent, name, email, password } = validated;

      // 1. Find OTP in DB
      const otpRecord = await prisma.otpVerification.findFirst({
        where: {
          phoneNumber: phone,
          code,
          intent,
          expiresAt: { gte: new Date() }
        },
        orderBy: { createdAt: 'desc' }
      });

      if (!otpRecord) {
        return res.status(401).json({ 
          error: 'Verification failed', 
          message: 'Invalid or expired OTP' 
        });
      }

      // 2. Clear used OTP
      await prisma.otpVerification.delete({ where: { id: otpRecord.id } });

      // 3. User Logic
      let user = await prisma.user.findUnique({ where: { phoneNumber: phone } });

      if (intent === 'register') {
        if (user) {
          return res.status(400).json({ 
            error: 'Account exists', 
            message: 'An account with this phone number already exists' 
          });
        }
        if (email) {
          const emailLower = email.toLowerCase();
          const emailCheck = await prisma.user.findUnique({ where: { email: emailLower } });
          if (emailCheck) {
            return res.status(400).json({ 
              error: 'Email exists', 
              message: 'An account with this email address already exists' 
            });
          }
        }

        const hashedPassword = password ? await authUtils.hashPassword(password) : null;
        const referralCode = await authUtils.generateReferralCode(prisma);

        user = await prisma.user.create({
          data: {
            phoneNumber: phone,
            name: name || `User ${phone.slice(-4)}`,
            email: email ? email.toLowerCase() : null,
            password: hashedPassword,
            referralCode
          }
        });
      } else if (intent === 'reset-password') {
        if (!user) {
          return res.status(404).json({ error: 'Not found', message: 'No account found with this phone number' });
        }
        if (password) {
          user = await prisma.user.update({
            where: { id: user.id },
            data: {
              password: await authUtils.hashPassword(password)
            }
          });
        }
      } else {
        // Standard login intent
        if (!user) {
          return res.status(404).json({ error: 'Not found', message: 'Account not found. Please register first.' });
        }
      }

      // Generate JWT
      const token = jwt.sign(
        { userId: user.id, phone: user.phoneNumber },
        process.env.JWT_SECRET || 'fallback_secret',
        { expiresIn: '30d' }
      );

      res.json({
        success: true,
        message: intent === 'reset-password' ? 'Password reset successfully' : 'Login verified',
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          referralCode: user.referralCode
        }
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ 
          error: 'Validation failed', 
          details: error.errors.map(e => e.message) 
        });
      }
      console.error('Verify OTP Error:', error);
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }

  /**
   * Placeholder Login for Flutter ApiService call
   */
  async login(req, res) {
    try {
      // Standardize input
      const data = {
        phone: req.body.phone || req.body.phoneNumber,
        password: req.body.password
      };

      // Validate
      const validated = loginSchema.parse(data);
      const { phone, password } = validated;

      const isEmail = phone.includes('@');
      const user = await prisma.user.findUnique({
        where: isEmail ? { email: phone.toLowerCase() } : { phoneNumber: phone }
      });

      if (!user || !user.password) {
        return res.status(401).json({ 
          error: 'Authentication failed', 
          message: 'Invalid phone number or password' 
        });
      }

      const isMatch = await authUtils.comparePassword(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ 
          error: 'Authentication failed', 
          message: 'Invalid phone number or password' 
        });
      }

      // Generate JWT
      const token = jwt.sign(
        { userId: user.id, phone: user.phoneNumber },
        process.env.JWT_SECRET || 'fallback_secret',
        { expiresIn: '30d' }
      );

      res.json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          referralCode: user.referralCode
        }
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ 
          error: 'Validation failed', 
          details: error.errors.map(e => e.message) 
        });
      }
      console.error('Login Error:', error);
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }
}

module.exports = new AuthController();
