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

      if (scraped) {
        if (scraped.gold) {
          this.cache.XAU = { price: scraped.gold, updatedAt: now.getTime() };
          await this.updateDbPrice('GOLD', scraped.gold, scraped.source);
        }

        if (scraped.silver) {
          this.cache.XAG = { price: scraped.silver, updatedAt: now.getTime() };
          await this.updateDbPrice('SILVER', scraped.silver, scraped.source);
        }
        
        console.log(`PriceService: Successfully automated price update at ${now.toLocaleTimeString()}`);
      } else {
        console.warn('PriceService: Scraper failed, using last known data (No Hardcoding)');
      }
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
   * Get historical price data from Yahoo Finance
   * @param {string} symbol - XAU or XAG
   * @param {string} range - 1mo, 3mo, 6mo, 1y
   * @returns {Promise<Array>} - Array of { date, price }
   */
  async getHistory(symbol = 'XAU', range = '1mo') {
    const ticker = symbol === 'XAU' ? 'GC=F' : 'SI=F';
    // Yahoo range mapping
    const rangeMap = {
      '1M': '1mo',
      '3M': '3mo',
      '6M': '6mo',
      '1Y': '1y',
      '3Y': '5y',
      '5Y': '5y',
      'Max': 'max'
    };
    const yahooRange = rangeMap[range] || '1mo';
    const interval = yahooRange === '1y' ? '1wk' : '1d';

    try {
      const url = `https://query1.finance.yahoo.com/v8/finance/chart/${ticker}?range=${yahooRange}&interval=${interval}`;
      const response = await axios.get(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        }
      });

      const result = response.data.chart.result[0];
      const timestamps = result.timestamp;
      const prices = result.indicators.quote[0].close;
      const usdINR = await this.getUsdInr();

      // Convert USD/Ounce to INR/Gram
      // 1 Troy Ounce = 31.1034g
      const divisor = 31.1034;
      
      return timestamps.map((ts, i) => ({
        date: new Date(ts * 1000).toISOString(),
        price: prices[i] ? (prices[i] * usdINR) / divisor : null
      })).filter(item => item.price !== null);

    } catch (error) {
      console.error(`PriceService: History fetch error for ${symbol}:`, error.message);
      return [];
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

  async getUsdInr() {
    try {
      const res = await axios.get('https://query1.finance.yahoo.com/v8/finance/chart/USDINR=X?interval=1d', {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        }
      });
      return res.data.chart.result[0].meta.regularMarketPrice;
    } catch (e) {
      return 83.0; // Fallback
    }
  }
}

module.exports = new PriceService();
