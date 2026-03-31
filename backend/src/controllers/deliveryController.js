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

      // 2. Perform Transactional Deduction
      const result = await prisma.$transaction(async (tx) => {
        const user = await tx.user.findUnique({ where: { id: userId } });
        
        const balance = metalType === 'GOLD' ? user.goldBalance : user.silverBalance;
        if (balance < weight) {
          throw new Error('Insufficient metal balance for delivery');
        }

        // Deduct Balance
        await tx.user.update({
          where: { id: userId },
          data: {
            [metalType === 'GOLD' ? 'goldBalance' : 'silverBalance']: { decrement: weight }
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

        // Create Transaction History Log
        await tx.transaction.create({
          data: {
            userId,
            type: 'WITHDRAWAL', // Using WITHDRAWAL for physical delivery
            metalType,
            weight,
            amount: 0, // No INR value for redemption? Or track spot value?
            status: 'COMPLETED'
          }
        });

        return delivery;
      });

      res.status(201).json({ 
        success: true, 
        message: 'Delivery request initiated', 
        delivery: result 
      });
    } catch (error) {
      if (error.name === 'ZodError') {
        return res.status(400).json({ error: 'Validation failed', details: error.errors.map(e => e.message) });
      }
      console.error('Delivery Error:', error.message);
      res.status(500).json({ error: error.message || 'Internal Server Error' });
    }
  }
}

module.exports = new DeliveryController();
