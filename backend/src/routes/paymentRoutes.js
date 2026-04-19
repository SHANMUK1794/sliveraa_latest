const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const authMiddleware = require('../middlewares/auth');
const checkKyc = require('../middlewares/kyc');

router.post('/orders', authMiddleware, checkKyc, paymentController.createOrder.bind(paymentController));
router.post('/create-order', authMiddleware, checkKyc, paymentController.createOrder.bind(paymentController));
router.post('/verify', authMiddleware, paymentController.verifyPayment.bind(paymentController));
router.post('/verify-payment', authMiddleware, paymentController.verifyPayment.bind(paymentController));
router.post('/webhook', paymentController.webhookHandler.bind(paymentController));

module.exports = router;
