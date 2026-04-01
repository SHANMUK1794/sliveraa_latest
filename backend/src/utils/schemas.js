const { z } = require('zod');

// Shared schemas
const phoneSchema = z.string().regex(/^[0-9]{10,12}$/, "Invalid phone number format");
const passwordSchema = z.string()
  .min(8, "Password must be at least 8 characters")
  .regex(/[A-Z]/, "Password must include at least one uppercase letter")
  .regex(/[a-z]/, "Password must include at least one lowercase letter")
  .regex(/[0-9]/, "Password must include at least one number")
  .regex(/[^A-Za-z0-9]/, "Password must include at least one special character");

// Auth Schemas
const registerSchema = z.object({
  name: z.string().min(2, "Name is too short"),
  email: z.string().email("Invalid email address"),
  phone: phoneSchema,
  password: passwordSchema,
  code: z.string().optional() // SMS OTP code
});

const loginSchema = z.object({
  phone: z.string().min(1, "Phone or Email is required"),
  password: z.string().min(1, "Password is required")
});

const sendOtpSchema = z.object({
  phone: phoneSchema,
  email: z.preprocess((val) => val === '' ? undefined : val, z.string().email().optional()),
  intent: z.enum(['register', 'login', 'reset-password'], {
    errorMap: () => ({ message: "Invalid intent. Must be 'register', 'login', or 'reset-password'" })
  })
});

const verifyOtpSchema = z.object({
  phone: phoneSchema,
  code: z.string().length(6, "OTP must be 6 digits"),
  intent: z.enum(['register', 'login', 'reset-password']),
  name: z.string().optional(),
  email: z.string().email().optional(),
  password: passwordSchema.optional(),
  referredBy: z.string().optional() // New field for referral tracking
});

// KYC Schemas
const kycStartSchema = z.object({
  idType: z.enum(['AADHAAR', 'PAN']),
  idNumber: z.string().min(10, "Identification number is too short")
});

const addressSchema = z.object({
  label: z.string().default("Home"),
  line1: z.string().min(5, "Address line 1 is too short"),
  line2: z.string().optional(),
  city: z.string().min(2, "City is required"),
  state: z.string().min(2, "State is required"),
  pincode: z.string().regex(/^[0-9]{6}$/, "Invalid pincode format"),
  isDefault: z.boolean().optional().default(false)
});

const deliveryRequestSchema = z.object({
  addressId: z.string().uuid("Invalid address ID"),
  metalType: z.enum(['GOLD', 'SILVER']),
  weight: z.number().positive("Weight must be positive")
});

const savingsPlanSchema = z.object({
  metalType: z.enum(['GOLD', 'SILVER']),
  amount: z.number().min(500, "Minimum SIP amount is ₹500"),
  frequency: z.enum(['MONTHLY']).default('MONTHLY')
});

// Payment Schemas
const createOrderSchema = z.object({
  amount: z.number().positive("Amount must be positive"),
  assetType: z.enum(['GOLD', 'SILVER']),
  grams: z.number().positive(),
  userId: z.string()
});

const verifyPaymentSchema = z.object({
  razorpay_order_id: z.string(),
  razorpay_payment_id: z.string(),
  razorpay_signature: z.string(),
  userId: z.string()
});

module.exports = {
  registerSchema,
  loginSchema,
  sendOtpSchema,
  verifyOtpSchema,
  kycStartSchema,
  createOrderSchema,
  verifyPaymentSchema,
  addressSchema,
  deliveryRequestSchema,
  savingsPlanSchema
};
