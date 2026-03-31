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
      const { phone, intent } = validated;

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
      await otpService.sendOtp(phone, code);

      res.status(200).json({ success: true, message: 'OTP sent successfully' });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      console.error('Send OTP Error:', error.message);
      res.status(500).json({ error: 'Failed to send OTP' });
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
          const emailCheck = await prisma.user.findUnique({ where: { email } });
          if (emailCheck) {
            return res.status(400).json({ 
              error: 'Email exists', 
              message: 'An account with this email address already exists' 
            });
          }
        }

        const hashedPassword = password ? await authUtils.hashPassword(password) : null;

        user = await prisma.user.create({
          data: {
            phoneNumber: phone,
            name: name || `User ${phone.slice(-4)}`,
            email: email || null,
            password: hashedPassword
          }
        });
      } else if (intent === 'reset-password') {
        if (!user) {
          return res.status(404).json({ error: 'Not found', message: 'No account found with this phone number' });
        }
        if (!password) {
          return res.status(400).json({ error: 'Input required', message: 'New password is required for reset' });
        }

        user = await prisma.user.update({
          where: { id: user.id },
          data: {
            password: await authUtils.hashPassword(password)
          }
        });
      } else {
        // Standard login intent
        if (!user) {
          // Auto-registration for login if no account exists (legacy support)
          user = await prisma.user.create({
            data: {
              phoneNumber: phone,
              name: name || `User ${phone.slice(-4)}`,
              email: email || null
            }
          });
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
          phoneNumber: user.phoneNumber
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

      const user = await prisma.user.findUnique({
        where: { phoneNumber: phone }
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
          phoneNumber: user.phoneNumber
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
