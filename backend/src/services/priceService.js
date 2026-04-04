const axios = require('axios');
const { scrapePrices } = require('../utils/priceScraper');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class PriceService {
  constructor() {
    this.apiKey = process.env.PRICE_API_KEY;
    this.baseUrl = 'https://www.goldapi.io/api';
    this.cache = {
      XAU: { price: 0, updatedAt: 0 },
      XAG: { price: 0, updatedAt: 0 },
    };
    this.cacheDuration = 30 * 1000; // 30 second background refresh
  }

  /**
   * Start the background auto-update process
   * Updates every 30 seconds to stay in sync with frontend
   */
  async initAutoUpdate() {
    console.log('PriceService: Initializing dynamic price automation (No Hardcoding)...');
    
    // 1. Try to populate initial cache from DB
    try {
      const dbGold = await prisma.metalPrice.findUnique({ where: { metalType: 'GOLD' } });
      const dbSilver = await prisma.metalPrice.findUnique({ where: { metalType: 'SILVER' } });
      
      if (dbGold) this.cache.XAU = { price: dbGold.price, updatedAt: dbGold.updatedAt.getTime() };
      if (dbSilver) this.cache.XAG = { price: dbSilver.price, updatedAt: dbSilver.updatedAt.getTime() };
    } catch (e) {
      console.warn('PriceService: Could not load initial prices from DB');
    }

    // 2. Immediate fetch from web
    await this.refreshPricesFromSource();

    // 3. Set interval for every 30 seconds
    setInterval(async () => {
      await this.refreshPricesFromSource();
    }, 30 * 1000);
  }

  async refreshPricesFromSource() {
    try {
      const scraped = await scrapePrices();
      const now = new Date();

      if (scraped.gold) {
        this.cache.XAU = { price: scraped.gold, updatedAt: now.getTime() };
        await this.updateDbPrice('GOLD', scraped.gold, scraped.source);
      }

      if (scraped.silver) {
        this.cache.XAG = { price: scraped.silver, updatedAt: now.getTime() };
        await this.updateDbPrice('SILVER', scraped.silver, scraped.source);
      }
      
      console.log(`PriceService: Successfully automated price update at ${now.toLocaleTimeString()}`);
    } catch (error) {
      console.error('PriceService: Auto-update error:', error.message);
    }
  }

  async updateDbPrice(metalType, price, source) {
    try {
      await prisma.metalPrice.upsert({
        where: { metalType },
        update: { price, source, updatedAt: new Date() },
        create: { metalType, price, source },
      });
    } catch (e) {
      console.error(`PriceService: DB sync error for ${metalType}:`, e.message);
    }
  }

  /**
   * Get Live Price of Gold or Silver (Price per Gram)
   * @param {string} symbol - XAU (Gold) or XAG (Silver)
   * @returns {Promise<number>}
   */
  async getLivePrice(symbol = 'XAU') {
    // Return from background cache immediately for "live" feel
    return this.cache[symbol].price;
  }

  /**
   * Convert gram weight to price based on current market
   */
  async calculatePrice(symbol, weightInGrams) {
    const pricePerGram = await this.getLivePrice(symbol);
    return pricePerGram * weightInGrams;
  }
}

module.exports = new PriceService();
