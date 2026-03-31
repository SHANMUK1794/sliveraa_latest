const express = require('express');
const router = express.Router();
const savingsController = require('../controllers/savingsController');
const rewardController = require('../controllers/rewardController');
const authMiddleware = require('../middlewares/auth');

router.use(authMiddleware);

// Savings Plans (SIPs)
router.post('/savings/plans', savingsController.createPlan);
router.get('/savings/plans', savingsController.getPlans);

// Rewards
router.get('/rewards', rewardController.getRewards);
router.post('/rewards/referral', rewardController.addReferralReward);

module.exports = router;
