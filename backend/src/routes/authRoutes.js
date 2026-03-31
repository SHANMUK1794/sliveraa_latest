const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/login', authController.login);
router.post('/send-otp', authController.sendOtp);
router.post('/verify-otp', authController.verifyOtp);
router.post('/forgot-password', authController.sendOtp); // Same as send-otp
router.post('/reset-password', authController.verifyOtp); // Same logic as verify-otp with intent

module.exports = router;
