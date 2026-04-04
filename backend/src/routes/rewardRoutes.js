const express = require('express');
const router = express.Router();
const rewardController = require('../controllers/rewardController');
const authMiddleware = require('../middlewares/auth');

// All reward routes require authentication
router.use(authMiddleware);

router.get('/', rewardController.getRewards);
router.post('/redeem', rewardController.redeemPoints);
router.post('/start-spin', rewardController.startSpin);
router.post('/claim-spin', rewardController.claimSpinReward);

module.exports = router;
