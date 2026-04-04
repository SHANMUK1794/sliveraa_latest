const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const authMiddleware = require('../middlewares/auth');
const checkKyc = require('../middlewares/kyc');

router.use(authMiddleware);

router.post('/withdraw', checkKyc, transactionController.withdraw);
router.get('/', transactionController.getTransactions);

module.exports = router;
