const express = require('express');
const router = express.Router();
const deliveryController = require('../controllers/deliveryController');
const authMiddleware = require('../middlewares/auth');

router.use(authMiddleware);

router.post('/addresses', deliveryController.addAddress);
router.get('/addresses', deliveryController.getAddresses);
router.post('/request', deliveryController.requestDelivery);

module.exports = router;
