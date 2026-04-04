const priceService = require('../services/priceService');

exports.getChatResponse = async (req, res) => {
  try {
    const { message } = req.body;
    const msg = message.toLowerCase();

    let response = "I'm Silvra's AI Assistant. How can I help you today?";

    // 1. Gold Price
    if ((msg.includes('gold') || msg.includes('price')) && (msg.includes('rate') || msg.includes('what'))) {
      const prices = await priceService.getLatestPrices();
      response = `The current live price for 24K Gold is ₹${prices.gold.price_per_gram.toLocaleString('en-IN')}/gm (excluding GST). Prices are updated every few minutes from international markets.`;
    } 
    // 2. Silver Price
    else if ((msg.includes('silver') || msg.includes('price')) && (msg.includes('rate') || msg.includes('what'))) {
      const prices = await priceService.getLatestPrices();
      response = `Fine Silver (99.9%) is currently trading at ₹${prices.silver.price_per_gram.toLocaleString('en-IN')}/gm. It's a great choice for long-term wealth accumulation!`;
    } 
    // 3. Physical Delivery
    else if (msg.includes('delivery') || msg.includes('physical') || msg.includes('ship')) {
      response = "You can request physical delivery of your vaulted gold or silver in the form of certified coins and bars (starting from 0.5g). Simply go to the 'Delivery' section in the app to place a request.";
    } 
    // 4. Withdrawals / Bank
    else if (msg.includes('withdraw') || msg.includes('money') || msg.includes('bank') || msg.includes('cash')) {
      response = "To withdraw, sell your holdings in the 'Portfolio' section and the funds will be credited to your linked primary bank account within 24-48 business hours.";
    } 
    // 5. Security / Trust
    else if (msg.includes('safe') || msg.includes('vault') || msg.includes('secure') || msg.includes('trust')) {
      response = "Your gold is 100% insured and stored in Grade-A secure bank vaults managed by regulated custodians like Brinks. We undergo regular audits to ensure your holdings are always backed 1:1.";
    }
    // 6. Rewards / Spin
    else if (msg.includes('reward') || msg.includes('spin') || msg.includes('win') || msg.includes('point')) {
      response = "Check out the Rewards Center! You can spin the wheel to win Gold, Silver, Aura Coins, or discount coupons. You also earn 'Aura Points' for every purchase you make.";
    }
    // 7. KYC / PAN
    else if (msg.includes('kyc') || msg.includes('pan') || msg.includes('verify')) {
      response = "KYC is a simple one-time process. You only need your PAN card. Go to Profile > KYC to complete it using our secure DigiLocker integration.";
    }
    else {
      response = "I'm not quite sure I understand that. Feel free to ask me about gold prices, how delivery works, or how to withdraw your funds!";
    }

    res.json({
      success: true,
      reply: response,
      timestamp: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true })
    });
  } catch (error) {
    console.error('Chatbot Error:', error);
    res.status(500).json({ success: false, message: 'Chatbot service temporarily unavailable' });
  }
};
