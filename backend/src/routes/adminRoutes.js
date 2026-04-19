const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middlewares/auth');
const adminMiddleware = require('../middlewares/admin');
const superAdminMiddleware = require('../middlewares/superAdmin');

// All routes here are protected by Auth and Admin middlewares
router.use(authMiddleware);
router.use(adminMiddleware);

router.get('/metrics', adminController.getMetrics);
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserDetails);
router.get('/deliveries', adminController.getDeliveries);
router.patch('/deliveries/:id', adminController.updateDelivery);
router.get('/transactions', adminController.getTransactions);
router.get('/sips', adminController.getSips);
router.patch('/kyc/:id', adminController.processKyc);

// Routes requiring Super Admin
router.post('/users', superAdminMiddleware, adminController.createUser);
router.patch('/users/:id/role', superAdminMiddleware, adminController.updateUserRole);

module.exports = router;
