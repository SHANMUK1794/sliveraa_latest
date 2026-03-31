const express = require('express');
const router = express.Router();
const priceController = require('../controllers/priceController');

router.get('/live', priceController.getPrices);

module.exports = router;
