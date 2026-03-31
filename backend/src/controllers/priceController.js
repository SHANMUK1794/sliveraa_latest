const priceService = require('../services/priceService');
const prisma = require('../models/prisma');

class PriceController {
  /**
   * Get Live Prices
   */
  async getPrices(req, res) {
    try {
      const goldPrice = await priceService.getLivePrice('XAU', 'INR');
      const silverPrice = await priceService.getLivePrice('XAG', 'INR');

      // Update in DB (Upsert)
      await Promise.all([
        prisma.metalPrice.upsert({
          where: { metalType: 'GOLD' },
          update: { price: goldPrice },
          create: { metalType: 'GOLD', price: goldPrice }
        }),
        prisma.metalPrice.upsert({
          where: { metalType: 'SILVER' },
          update: { price: silverPrice },
          create: { metalType: 'SILVER', price: silverPrice }
        })
      ]);

      res.json({
        gold: { symbol: 'XAU', price: goldPrice, currency: 'INR' },
        silver: { symbol: 'XAG', price: silverPrice, currency: 'INR' },
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Fetch Prices Error:', error);
      res.status(500).json({ error: 'Failed to fetch metal prices' });
    }
  }
}

module.exports = new PriceController();
