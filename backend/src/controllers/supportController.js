const priceService = require('../services/priceService');

exports.getChatResponse = async (req, res) => {
  try {
    const { message } = req.body;
    const msg = message.toLowerCase();

    let response = "I'm Silvra's AI Assistant. How can I help you today?";

    if (msg.includes('gold') && msg.includes('price')) {
      const prices = await priceService.getLatestPrices();
      response = `Currently, 24K Gold is trading at ₹${prices.gold.price_per_gram.toLocaleString('en-IN')}/gm. It's a great time to start your accumulation journey!`;
    } else if (msg.includes('silver') && msg.includes('price')) {
      const prices = await priceService.getLatestPrices();
      response = `Fine Silver is currently priced at ₹${prices.silver.price_per_gram.toLocaleString('en-IN')}/gm. You can start investing with as little as ₹50.`;
    } else if (msg.includes('withdraw') || msg.includes('bank')) {
      response = "You can withdraw your funds to your primary bank account via the Portfolio screen. Usually, it takes 24-48 hours for the funds to reflect.";
    } else if (msg.includes('kyc') || msg.includes('pan')) {
      response = "KYC is required for transactions above ₹2 Lakhs. You can complete your Pan verification in the Profile section.";
    } else if (msg.includes('savings') || msg.includes('plan')) {
      response = "Our Digital Vault Savings Plan allows you to accumulate Gold/Silver daily, weekly, or monthly. We now offer 5-year projections at 14% P.A.!";
    } else if (msg.includes('reward') || msg.includes('spin')) {
      response = "You can win Gold, Aura Coins, and coupons by spinning the wheel in the Rewards section. Don't forget to check your Referral rewards too!";
    } else {
      response = "Thank you for reaching out! I've received your message: \"" + message + "\". Our concierge team will monitor this chat, but feel free to ask me about gold prices, savings plans, or withdrawals!";
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
