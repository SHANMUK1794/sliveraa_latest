const express = require('express');
const router = express.Router();
const deliveryController = require('../controllers/deliveryController');
const authMiddleware = require('../middlewares/auth');
const checkKyc = require('../middlewares/kyc');

router.use(authMiddleware);

router.post('/addresses', deliveryController.addAddress);
router.get('/addresses', deliveryController.getAddresses);
router.post('/request', checkKyc, deliveryController.requestDelivery);
router.get('/me', deliveryController.getDeliveries);

module.exports = router;
