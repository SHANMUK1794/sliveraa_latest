const { scrapePrices } = require('./src/utils/priceScraper');

async function test() {
    console.log('Testing Price Scraper...');
    const prices = await scrapePrices();
    console.log('Final Result:', prices);
}

test();
