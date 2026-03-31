const prisma = require('../models/prisma');

/**
 * Middleware to restrict transactional actions to KYC verified users
 */
const checkKyc = async (req, res, next) => {
  try {
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({ 
        error: 'Authentication required',
        message: 'No user ID found in request' 
      });
    }

    // Fetch the latest KYC status from the database
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { kycStatus: true }
    });

    if (!user) {
      return res.status(404).json({ 
        error: 'User not found',
        message: 'The authenticated user does not exist in our records' 
      });
    }

    // Only allow VERIFIED status
    if (user.kycStatus !== 'VERIFIED') {
      return res.status(403).json({ 
        error: 'KYC Required',
        message: 'Please complete your Aadhaar/PAN verification to perform this action',
        kycStatus: user.kycStatus 
      });
    }

    next();
  } catch (error) {
    console.error('KYC Middleware Error:', error.message);
    return res.status(500).json({ 
      error: 'Security Check Failed',
      message: 'Unable to verify your KYC status at this time'
    });
  }
};

module.exports = checkKyc;
