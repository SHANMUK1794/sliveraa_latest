const axios = require('axios');

/**
 * Scrapes live Delhi Gold and Silver prices.
 * Targets: 24K Gold (per gram) and 999 Silver (per gram).
 */
async function scrapePrices() {
    // Default Fallback (Approx Delhi Rates if scraping fails)
    const prices = {
        gold: 7510.0,
        silver: 98.5,
        source: 'Fallback (Market Average)',
        timestamp: new Date()
    };

    const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    };

    try {
        // Source 1: Bullion-Rates (Very table-friendly for scraping)
        const gRes = await axios.get('https://www.bullion-rates.com/gold/INR/24k-per-gram-price.htm', { headers, timeout: 10000 });
        const gHtml = gRes.data;
        const gMatch = gHtml.match(/<span[^>]*>([\d,.]+)\s*<\/span>/i) || gHtml.match(/Gold price per gram in India.*?([\d,.]+)/i);
        
        if (gMatch && gMatch[1]) {
            prices.gold = parseFloat(gMatch[1].replace(/,/g, ''));
            prices.source = 'Bullion-Rates (India)';
        }

        // Source 2: Moneycontrol Delhi Silver fallback
        const sRes = await axios.get('https://www.bullion-rates.com/silver/INR-price.htm', { headers, timeout: 10000 });
        const sHtml = sRes.data;
        const sMatch = sHtml.match(/Silver price per gram.*?([\d,.]+)/i) || sHtml.match(/<span[^>]*>([\d,.]+)\s*<\/span>/i);
        
        if (sMatch && sMatch[1]) {
            prices.silver = parseFloat(sMatch[1].replace(/,/g, ''));
        }

        // If we got valid numbers, we're good
        if (prices.gold > 1000 && prices.silver > 50) {
            console.log(`PriceScraper: Success. Gold: ${prices.gold}, Silver: ${prices.silver}`);
            return prices;
        }

        throw new Error('Prices outside expected range');

    } catch (error) {
        console.error('PriceScraper Web Error:', error.message);
        // If web fails, use a semi-live approximation for Delhi (Gold is approx Rs 7500 per gram now)
        return prices; 
    }
}

module.exports = { scrapePrices };
