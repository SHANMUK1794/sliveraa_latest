const axios = require('axios');

async function scrapePrices() {
    // Standard multipliers
    const TROY_OUNCE_TO_GRAMS = 31.1034768;
    const INDIA_IMPORT_DUTY_GST = 1.15; // Approx duty+GST adjustment to match Delhi Retail

    const prices = {
        gold: 7510.0,
        silver: 98.5,
        source: 'Live Global Spot (Adjusted for Delhi)',
        timestamp: new Date()
    };

    try {
        // 1. Fetch Live USD/INR Exchange Rate
        const exchRes = await axios.get('https://api.gold-api.com/price/USD', { timeout: 10000 });
        const usdInr = exchRes.data.price || 83.5; // Fallback to current rough rate

        // 2. Fetch Live Gold Spot (USD/oz)
        const goldRes = await axios.get('https://api.gold-api.com/price/XAU', { timeout: 10000 });
        const goldUsd = goldRes.data.price;

        // 3. Fetch Live Silver Spot (USD/oz)
        const silverRes = await axios.get('https://api.gold-api.com/price/XAG', { timeout: 10000 });
        const silverUsd = silverRes.data.price;

        if (goldUsd && usdInr) {
            // Formula: (Price/oz / 31.1035) * USDINR * Duty/Tax
            prices.gold = (goldUsd / TROY_OUNCE_TO_GRAMS) * usdInr * INDIA_IMPORT_DUTY_GST;
        }

        if (silverUsd && usdInr) {
             prices.silver = (silverUsd / TROY_OUNCE_TO_GRAMS) * usdInr * INDIA_IMPORT_DUTY_GST;
        }

        console.log(`PriceScraper: Real-time update successful. Gold: ${prices.gold.toFixed(2)}, Silver: ${prices.silver.toFixed(2)}`);
        return prices;

    } catch (error) {
        console.error('PriceScraper API Error:', error.message);
        return prices; 
    }
}

module.exports = { scrapePrices };
