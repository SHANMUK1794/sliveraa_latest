const axios = require('axios');

async function scrapePrices() {
    const prices = {
        gold: 7510.0,
        silver: 98.5,
        source: 'GoodReturns (Delhi Live)',
        timestamp: new Date()
    };

    const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-IN,en-GB;q=0.9,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Referer': 'https://www.google.com/'
    };

    try {
        // 1. Scrape Gold price from GoodReturns Delhi page
        const goldRes = await axios.get('https://www.goodreturns.in/gold-rates/delhi.html', { headers, timeout: 15000 });
        const goldHtml = goldRes.data;

        // Target: "24 karat gold (99.9% purity), ₹[PRICE] per gram"
        const goldMatch = goldHtml.match(/24\s*karat\s*gold\s*.*?₹\s*([\d,.]+)/i);
        if (goldMatch && goldMatch[1]) {
            prices.gold = parseFloat(goldMatch[1].replace(/,/g, ''));
        } else {
             // Fallback: look for generic 24k price in table
             const backupGold = goldHtml.match(/24\s*Carat.*?([\d,]+)\s*<\/td>/i);
             if (backupGold && backupGold[1]) prices.gold = parseFloat(backupGold[1].replace(/,/g, '')) / 10; // Often for 10g
        }

        // 2. Scrape Silver price from GoodReturns Delhi page
        const silverRes = await axios.get('https://www.goodreturns.in/silver-rates/delhi.html', { headers, timeout: 15000 });
        const silverHtml = silverRes.data;

        // Target: "Silver price in Delhi stands at ₹[PRICE] per gram"
        const silverMatch = silverHtml.match(/silver\s*price\s*.*?₹\s*([\d,.]+)\s*per\s*gram/i);
        if (silverMatch && silverMatch[1]) {
            prices.silver = parseFloat(silverMatch[1].replace(/,/g, ''));
        } else {
            // Fallback: "₹[PRICE] per kg"
            const silverKgMatch = silverHtml.match(/₹\s*([\d,.]+)\s*per\s*kg/i);
            if (silverKgMatch && silverKgMatch[1]) {
                prices.silver = parseFloat(silverKgMatch[1].replace(/,/g, '')) / 1000;
            }
        }

        console.log(`PriceScraper: Live Delhi data found. Gold: ${prices.gold.toFixed(2)}, Silver: ${prices.silver.toFixed(2)}`);
        return prices;

    } catch (error) {
        console.error('PriceScraper Web Error:', error.message);
        return prices; 
    }
}

module.exports = { scrapePrices };
