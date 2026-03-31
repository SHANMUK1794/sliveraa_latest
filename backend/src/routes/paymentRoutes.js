const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const authMiddleware = require('../middlewares/auth');
const checkKyc = require('../middlewares/kyc');

router.post('/orders', authMiddleware, checkKyc, paymentController.createOrder);
router.post('/create-order', authMiddleware, checkKyc, paymentController.createOrder);
router.post('/verify', authMiddleware, paymentController.verifyPayment);
router.post('/verify-payment', authMiddleware, paymentController.verifyPayment);

module.exports = router;
