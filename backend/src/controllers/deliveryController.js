const prisma = require('../models/prisma');
const { addressSchema, deliveryRequestSchema } = require('../utils/schemas');

class DeliveryController {
  /**
   * Add new delivery address
   */
  async addAddress(req, res) {
    try {
      const { userId } = req.user;
      const validated = addressSchema.parse(req.body);

      // If it's the first address or marked as default, handle that
      const addressCount = await prisma.address.count({ where: { userId } });
      const isDefault = validated.isDefault || addressCount === 0;

      if (isDefault) {
        await prisma.address.updateMany({
          where: { userId },
          data: { isDefault: false }
        });
      }

      const address = await prisma.address.create({
        data: {
          ...validated,
          userId,
          isDefault
        }
      });

      res.status(201).json({ success: true, message: 'Address saved', address });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Get all user addresses
   */
  async getAddresses(req, res) {
    try {
      const { userId } = req.user;
      const addresses = await prisma.address.findMany({
        where: { userId },
        orderBy: { updatedAt: 'desc' }
      });
      res.json({ success: true, addresses });
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  }

  /**
   * Request Physical Delivery
   */
  async requestDelivery(req, res) {
    try {
      const { userId } = req.user;
      const validated = deliveryRequestSchema.parse(req.body);
      const { addressId, metalType, weight } = validated;

      // 1. Verify Address
      const address = await prisma.address.findFirst({
        where: { id: addressId, userId }
      });
      if (!address) return res.status(404).json({ error: 'Address not found' });

      // 2. Define Making Charges (Configurable)
      // Gold: ₹500/g, Silver: ₹50/g
      const MAKING_CHARGE_PER_GRAM = metalType === 'GOLD' ? 500 : 50;
      const totalMakingCharge = weight * MAKING_CHARGE_PER_GRAM;

      // 3. Perform Transactional Deduction
      const result = await prisma.$transaction(async (tx) => {
        const user = await tx.user.findUnique({ where: { id: userId } });
        
        // Check Metal Balance
        const metalBalance = metalType === 'GOLD' ? user.goldBalance : user.silverBalance;
        if (metalBalance < weight) {
          throw new Error(`Insufficient ${metalType} balance for delivery`);
        }

        // Check Wallet Balance for Making Charges
        if (user.walletBalance < totalMakingCharge) {
          throw new Error(`Insufficient wallet balance for making charges (Requires ₹${totalMakingCharge})`);
        }

        // Deduct Metal and Wallet Balance
        await tx.user.update({
          where: { id: userId },
          data: {
            [metalType === 'GOLD' ? 'goldBalance' : 'silverBalance']: { decrement: weight },
            walletBalance: { decrement: totalMakingCharge }
          }
        });

        // Create Delivery Request
        const delivery = await tx.deliveryRequest.create({
          data: {
            userId,
            addressId,
            metalType,
            weight,
            status: 'PENDING'
          }
        });

        // Create Transaction History Log (Metal Deduction)
        await tx.transaction.create({
          data: {
            userId,
            type: 'WITHDRAWAL',
            metalType,
            weight,
            amount: 0, 
            status: 'COMPLETED'
          }
        });

        // Create Transaction History Log (Making Charge)
        await tx.transaction.create({
          data: {
            userId,
            type: 'WITHDRAWAL', // Or a new type like 'SERVICE_FEE'
            amount: totalMakingCharge,
            status: 'COMPLETED'
          }
        });

        return { delivery, makingCharge: totalMakingCharge };
      });

      res.status(201).json({ 
        success: true, 
        message: 'Delivery request initiated', 
        data: result 
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      console.error('Delivery Error:', error.message);
      res.status(500).json({ error: error.message || 'Internal Server Error' });
    }
  }

  /**
   * Get all user delivery requests (Orders)
   */
  async getDeliveries(req, res) {
    try {
      const { userId } = req.user;
      const deliveries = await prisma.deliveryRequest.findMany({
        where: { userId },
        include: {
          address: true
        },
        orderBy: { createdAt: 'desc' }
      });
      res.json({ success: true, deliveries });
    } catch (error) {
      console.error('Fetch Deliveries Error:', error.message);
      res.status(500).json({ error: 'Failed to fetch orders' });
    }
  }
}

module.exports = new DeliveryController();
