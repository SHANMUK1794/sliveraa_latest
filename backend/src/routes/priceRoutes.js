const express = require('express');
const router = express.Router();
const priceController = require('../controllers/priceController');

router.get('/live', priceController.getPrices);
router.get('/history', priceController.getPriceHistory);

module.exports = router;
