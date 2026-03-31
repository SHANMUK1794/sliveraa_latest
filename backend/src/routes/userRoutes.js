const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/auth');

router.get('/profile', authMiddleware, userController.getProfile);
router.get('/me', authMiddleware, userController.getProfile);
router.get('/transactions', authMiddleware, userController.getTransactions);
router.patch('/update', authMiddleware, userController.updateProfile);

module.exports = router;
