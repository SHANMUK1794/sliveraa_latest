const axios = require('axios');

class PriceService {
  constructor() {
    this.apiKey = process.env.PRICE_API_KEY;
    this.baseUrl = 'https://www.goldapi.io/api';
    this.cache = {
      XAU: { price: 0, updatedAt: 0 },
      XAG: { price: 0, updatedAt: 0 },
    };
    this.cacheDuration = 5 * 60 * 1000; // 5 minutes cache
  }

  /**
   * Get Live Price of Gold or Silver
   * @param {string} symbol - XAU (Gold) or XAG (Silver)
   * @param {string} curr - Currency (e.g., INR)
   * @returns {Promise<number>}
   */
  async getLivePrice(symbol = 'XAU', curr = 'INR') {
    const now = Date.now();
    if (this.cache[symbol] && (now - this.cache[symbol].updatedAt < this.cacheDuration)) {
      return this.cache[symbol].price;
    }

    try {
      const response = await axios.get(`${this.baseUrl}/${symbol}/${curr}`, {
        headers: {
          'x-access-token': this.apiKey,
          'Content-Type': 'application/json',
        },
      });

      const price = response.data.price;
      this.cache[symbol] = { price, updatedAt: now };
      return price;
    } catch (error) {
      console.error(`GoldAPI Fetch Error (${symbol}):`, error.response?.data || error.message);
      // If error occurs, return last known price if available, or throw error
      if (this.cache[symbol].price > 0) return this.cache[symbol].price;
      throw new Error('Failed to fetch live prices');
    }
  }

  /**
   * Convert gram weight to price based on current market
   */
  async calculatePrice(symbol, weightInGrams) {
    const pricePerOunce = await this.getLivePrice(symbol);
    // 1 Troy Ounce = 31.1035 Grams
    const pricePerGram = pricePerOunce / 31.1034768;
    return pricePerGram * weightInGrams;
  }
}

module.exports = new PriceService();
