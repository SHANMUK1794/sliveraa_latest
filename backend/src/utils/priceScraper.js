const axios = require('axios');

/**
 * Scrapes live Delhi Gold and Silver prices.
 * Targets: 24K Gold (per gram) and 999 Silver (per gram).
 */
const axios = require('axios');
const cheerio = require('cheerio');

/**
 * Scrapes live Delhi Gold and Silver prices from GoodReturns.in
 * Targets: 24K Gold (per gram) and 999 Silver (per gram).
 */
async function scrapePrices() {
    const url = 'https://www.goodreturns.in/gold-rates/delhi.html';
    const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    };

    try {
        const { data: html } = await axios.get(url, { headers, timeout: 15000 });
        const $ = cheerio.load(html);
        
        let goldVal = null;
        let silverVal = null;

        // 1. Extract 24K Gold (1 Gram)
        // Table: Today 24 Carat Gold Rate Per Gram in Delhi
        $('div.oi-cms-db-content-block table').each((i, el) => {
            const firstRowText = $(el).find('tr').first().text();
            if (firstRowText.includes('24 Carat Gold Rate')) {
                const price_1g_raw = $(el).find('tr').eq(1).find('td').eq(1).text();
                goldVal = parseFloat(price_1g_raw.replace(/[^\d.]/g, ''));
                return false; 
            }
        });

        // 2. Extract Silver (1 Gram)
        // Table: Today Silver Price Per Gram/Kg in Delhi
        $('div.oi-cms-db-content-block table').each((i, el) => {
            const firstRowText = $(el).find('tr').first().text();
            if (firstRowText.toLowerCase().includes('silver price per gram')) {
                const silver_1g_raw = $(el).find('tr').eq(1).find('td').eq(1).text();
                silverVal = parseFloat(silver_1g_raw.replace(/[^\d.]/g, ''));
                return false;
            }
        });

        if (goldVal && silverVal) {
            console.log(`[PriceScraper] SUCCESS - Gold: ₹${goldVal}, Silver: ₹${silverVal}`);
            return {
                gold: goldVal,
                silver: silverVal,
                source: 'GoodReturns.in (Delhi)',
                timestamp: new Date()
            };
        }

        throw new Error('Failed to parse price tables from GoodReturns');

    } catch (error) {
        console.error('[PriceScraper] ERROR:', error.message);
        return null; // Return null to signal failure without fallback
    }
}

module.exports = { scrapePrices };
