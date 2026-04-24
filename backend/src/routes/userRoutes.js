const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/auth');

router.get('/profile', authMiddleware, userController.getProfile);
router.get('/me', authMiddleware, userController.getProfile);
router.get('/transactions', authMiddleware, userController.getTransactions);
router.patch('/update', authMiddleware, userController.updateProfile);
router.patch('/update-password', authMiddleware, userController.updatePassword);
router.delete('/delete-account', authMiddleware, userController.deleteAccount);

module.exports = router;
