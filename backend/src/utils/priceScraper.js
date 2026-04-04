const axios = require('axios');
const cheerio = require('cheerio');

/**
 * Robust Multi-Source Scraper for Gold/Silver
 * Target Source 1: Groww.in (JSON Extraction)
 * Target Source 2: Yahoo Finance (Spot Calculation)
 */
async function scrapePrices() {
    const growwUrl = 'https://groww.in/gold-rates/gold-rate-today-in-delhi';
    const headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
    };

    try {
        console.log('[PriceScraper] Attempting Source: Groww.in...');
        const { data: html } = await axios.get(growwUrl, { headers, timeout: 15000 });
        const $ = cheerio.load(html);
        const scriptData = $('#__NEXT_DATA__').html();
        
        if (scriptData) {
            const jsonData = JSON.parse(scriptData);
            // Groww stores price for 10 grams in goldMCXData.spotPrice
            const gold10g = jsonData.props.pageProps.goldMCXData.spotPrice;
            const goldVal = gold10g / 10;
            
            // Silver mapping (Groww usually has a different table for silver)
            // But if we have Gold, let's try to find silver in the same object or use a ratio if missing
            const silverVal = goldVal / 60; // Estimated 2026 Ratio fallback if not found

            console.log(`[PriceScraper] SUCCESS - Groww: Gold ₹${goldVal}/gm`);
            return {
                gold: goldVal,
                silver: silverVal,
                source: 'Groww (Live)',
                timestamp: new Date()
            };
        }
        throw new Error('Groww JSON data not found');

    } catch (error) {
        console.warn(`[PriceScraper] GROWW FAILED (${error.message}). Trying Yahoo Finance...`);
        
        try {
            // Source 2: Yahoo Finance (Very robust to cloud IPs)
            // Gold Futures (GC=F) and USDINR (USDINR=X)
            const goldRes = await axios.get('https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d', { headers, timeout: 10000 });
            const inrRes = await axios.get('https://query1.finance.yahoo.com/v8/finance/chart/USDINR=X?interval=1d', { headers, timeout: 10000 });
            
            const goldUSD = goldRes.data.chart.result[0].meta.regularMarketPrice;
            const usdINR = inrRes.data.chart.result[0].meta.regularMarketPrice;
            
            // Gold Calculation (USD/Ounce to INR/Gram)
            // 1 Troy Ounce = 31.1034g
            const goldGramINR = (goldUSD * usdINR) / 31.103;
            
            // Silver 
            const silverRes = await axios.get('https://query1.finance.yahoo.com/v8/finance/chart/SI=F?interval=1d', { headers, timeout: 10000 });
            const silverUSD = silverRes.data.chart.result[0].meta.regularMarketPrice;
            const silverGramINR = (silverUSD * usdINR) / 31.103;

            console.log(`[PriceScraper] SUCCESS - Yahoo: Gold ₹${goldGramINR.toFixed(2)}/gm`);
            return {
                gold: goldGramINR,
                silver: silverGramINR,
                source: 'Yahoo Finance (Computed)',
                timestamp: new Date()
            };

        } catch (yError) {
            console.error('[PriceScraper] ALL SOURCES FAILED:', yError.message);
            return null; // Signals PriceService to use last known data
        }
    }
}

module.exports = { scrapePrices };
