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

  /**
   * Get historical price data
   */
  async getPriceHistory(req, res) {
    try {
      const { metal, period } = req.query; // metal: GOLD/SILVER, period: 1M/3M/6M/1Y
      const symbol = metal === 'SILVER' ? 'XAG' : 'XAU';
      
      const history = await priceService.getHistory(symbol, period);
      
      res.json({
        metal,
        period,
        history
      });
    } catch (error) {
      console.error('Fetch History Error:', error);
      res.status(500).json({ error: 'Failed to fetch price history' });
    }
  }
}

module.exports = new PriceController();
