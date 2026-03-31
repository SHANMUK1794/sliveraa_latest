const express = require('express');
const router = express.Router();
const kycController = require('../controllers/kycController');
const authMiddleware = require('../middlewares/auth');

router.use(authMiddleware);

router.post('/start', kycController.startKyc);
router.get('/digilocker/init', kycController.initDigiLocker);
router.post('/submit-aadhaar-otp', kycController.submitAadhaarOtp);
router.get('/status', kycController.checkKycStatus); 
router.get('/status/:userId', kycController.checkKycStatus); 

module.exports = router;
