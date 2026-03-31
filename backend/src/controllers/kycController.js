const kycService = require('../services/kycService');
const prisma = require('../models/prisma');
const { kycStartSchema } = require('../utils/schemas');

class KycController {
  /**
   * Start KYC (Aadhaar or PAN)
   * Flutter payload: userId, idType, idNumber
   */
  async startKyc(req, res) {
    if (!kycService.isAvailable) {
      return res.status(501).json({ error: 'Not Implemented', message: 'KYC service is not configured' });
    }
    try {
      // Standardize input
      const data = {
        userId: req.body.userId || req.user?.userId,
        idType: req.body.idType,
        idNumber: req.body.idNumber
      };

      // Validate
      const validated = kycStartSchema.parse(data);
      const { userId, idType, idNumber } = validated;

      // Duplicate Check: Has another user already verified this document?
      const existingDoc = await prisma.kycDetail.findFirst({
        where: {
          documentNumber: idNumber,
          status: 'VERIFIED',
          NOT: { userId: userId }
        }
      });

      if (existingDoc) {
        return res.status(400).json({ 
          error: 'Duplicate Document', 
          message: 'This Aadhaar/PAN is already verified with another account' 
        });
      }

      let response;
      if (idType === 'AADHAAR') {
        response = await kycService.verifyAadhaar(idNumber);
        // Save initial state
        await prisma.kycDetail.upsert({
          where: { userId },
          update: {
            documentType: idType,
            documentNumber: idNumber,
            verificationId: response.data?.client_id || null,
            status: 'PENDING'
          },
          create: {
            userId,
            documentType: idType,
            documentNumber: idNumber,
            verificationId: response.data?.client_id || null,
            status: 'PENDING'
          }
        });
        return res.json({ success: true, message: 'Aadhaar OTP generated successfully', data: response.data });
      } else if (idType === 'PAN') {
        response = await kycService.verifyPan(idNumber);
        // Instant PAN verify
        await prisma.$transaction([
          prisma.kycDetail.upsert({
            where: { userId },
            update: {
              documentType: idType,
              documentNumber: idNumber,
              status: 'VERIFIED',
              verifiedAt: new Date(),
              rawResponse: response
            },
            create: {
              userId,
              documentType: idType,
              documentNumber: idNumber,
              status: 'VERIFIED',
              verifiedAt: new Date(),
              rawResponse: response
            }
          }),
          prisma.user.update({
            where: { id: userId },
            data: { kycStatus: 'VERIFIED' }
          })
        ]);
        return res.json({ success: true, message: 'PAN verified successfully', data: response.data });
      } else {
        return res.status(400).json({ error: 'Invalid ID Type', message: "Type must be 'AADHAAR' or 'PAN'" });
      }
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      console.error('Start KYC Error:', error.message);
      res.status(500).json({ error: 'KYC Initiation Failed', message: error.message });
    }
  }

  /**
   * Submit Aadhaar OTP (Step 2)
   */
  async submitAadhaarOtp(req, res) {
    if (!kycService.isAvailable) {
      return res.status(501).json({ error: 'Not Implemented', message: 'KYC service is not configured' });
    }
    try {
      const { userId } = req.user;
      const { clientId, otp } = req.body;

      if (!clientId || !otp) {
        return res.status(400).json({ error: 'Input required', message: 'Client ID and OTP are required' });
      }

      const response = await kycService.submitAadhaarOtp(clientId, otp);

      // Successfully verified?
      if (response.data?.status === 'SUCCESS' || response.status === 'success') {
        await prisma.$transaction([
          prisma.kycDetail.update({
            where: { userId },
            data: {
              status: 'VERIFIED',
              verifiedAt: new Date(),
              rawResponse: response
            }
          }),
          prisma.user.update({
            where: { id: userId },
            data: { kycStatus: 'VERIFIED' }
          })
        ]);
        return res.json({ success: true, message: 'Aadhaar verified successfully', data: response.data });
      }

      return res.status(400).json({ error: 'Verification failed', message: response.message || 'OTP verification failed' });
    } catch (error) {
      console.error('Submit KYC Error:', error.message);
      res.status(500).json({ error: 'Verification Failed', message: error.message });
    }
  }

  /**
   * Initialize DigiLocker WebSDK Session
   * Flutter route: kyc/digilocker/init
   */
  async initDigiLocker(req, res) {
    try {
      const userId = req.user?.userId;

      // 1. Check if user is already verified
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { kycStatus: true }
      });

      if (user?.kycStatus === 'VERIFIED') {
        return res.status(400).json({ 
          error: 'KYC Already Completed', 
          message: 'You have already verified your documents successfully' 
        });
      }

      const response = await kycService.createDigiLockerSession(userId);
      res.json(response);
    } catch (error) {
      console.error('Init DigiLocker Error:', error.message);
      res.status(500).json({ error: 'Failed to initialize DigiLocker session', message: error.message });
    }
  }

  /**
   * Finalize DigiLocker Verification (Step 3)
   * This is called by the frontend after SDK SUCCESS callback
   */
  async finalizeDigiLocker(req, res) {
    try {
      const { userId } = req.user;
      const { clientId } = req.body;

      if (!clientId) {
        return res.status(400).json({ error: 'Input required', message: 'Client ID is required to fetch results' });
      }

      const response = await kycService.getDigiLockerResult(clientId);

      // Status check
      if (response.success || response.status_code === 200) {
        const aadhaarData = response.data?.aadhaar_xml_data || {};
        const aadhaarNumber = aadhaarData.masked_aadhaar || 'DIGILOCKER_VERIFIED'; // Masked Aadhar for tracking

        // Duplicate Check: Ensure this person isn't already verified elsewhere
        // We check against the unique ID provided by Surepass if available
        const docNumber = response.data?.digilocker_metadata?.name + response.data?.digilocker_metadata?.dob; // Fallback unique key
        
        const existingIdentity = await prisma.kycDetail.findFirst({
            where: {
                documentNumber: docNumber,
                status: 'VERIFIED',
                NOT: { userId: userId }
            }
        });

        if (existingIdentity) {
            return res.status(400).json({ 
                error: 'Identity Already Verified', 
                message: 'This Aadhaar identity is already linked to another account' 
            });
        }

        await prisma.$transaction([
          prisma.kycDetail.upsert({
            where: { userId },
            update: {
              status: 'VERIFIED',
              verifiedAt: new Date(),
              documentNumber: docNumber,
              rawResponse: response
            },
            create: {
              userId,
              documentType: 'AADHAAR',
              documentNumber: docNumber,
              status: 'VERIFIED',
              verifiedAt: new Date(),
              rawResponse: response
            }
          }),
          prisma.user.update({
            where: { id: userId },
            data: { kycStatus: 'VERIFIED' }
          })
        ]);
        return res.json({ success: true, message: 'KYC results finalized and stored', data: response.data });
      }

      return res.status(400).json({ 
        error: 'Verification incomplete', 
        message: 'Surepass did not return a successful verification status' 
      });
    } catch (error) {
      console.error('Finalize DigiLocker Error:', error.message);
      res.status(500).json({ error: 'Failed to finalize verification', message: error.message });
    }
  }

  /**
   * Check KYC Status
   * Flutter route: kyc/status/:userId
   */
  async checkKycStatus(req, res) {
    const userId = req.params.userId || req.user?.userId;
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { kycDetails: true }
      });

      if (!user) return res.status(404).json({ error: 'User not found' });

      res.json({
        kycStatus: user.kycStatus,
        details: user.kycDetails
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to retrieve KYC status' });
    }
  }
}

module.exports = new KycController();
