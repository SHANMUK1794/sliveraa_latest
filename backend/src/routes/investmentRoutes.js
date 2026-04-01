const express = require('express');
const router = express.Router();
const savingsController = require('../controllers/savingsController');
const rewardController = require('../controllers/rewardController');
const authMiddleware = require('../middlewares/auth');
const checkKyc = require('../middlewares/kyc');

router.use(authMiddleware);

// Savings Plans (SIPs) - REQUIRES KYC
router.post('/savings/plans', checkKyc, savingsController.createPlan);
router.get('/savings/plans', savingsController.getPlans);
router.post('/savings/process-dues', savingsController.processDuePayments); // Add this for testing/admin

// Rewards
router.get('/rewards', rewardController.getRewards);
router.post('/rewards/redeem', rewardController.redeemPoints);
router.post('/rewards/referral', rewardController.addReferralReward);

module.exports = router;
