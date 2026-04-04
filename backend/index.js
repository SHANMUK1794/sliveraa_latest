const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const authRoutes = require('./src/routes/authRoutes');
const profileRoutes = require('./src/routes/userRoutes'); // Renamed internally for clarity
const priceRoutes = require('./src/routes/priceRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const kycRoutes = require('./src/routes/kycRoutes');
const deliveryRoutes = require('./src/routes/deliveryRoutes');
const investmentRoutes = require('./src/routes/investmentRoutes');
const rewardRoutes = require('./src/routes/rewardRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes aligned with Flutter ApiService
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes); // Matches profile/me
app.use('/api/prices', priceRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/kyc', kycRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/invest', investmentRoutes);
app.use('/api/rewards', rewardRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Silvra Backend is running' });
});

// Error handling middleware
const priceService = require('./src/services/priceService');

app.listen(PORT, () => {
  console.log(`🚀 Silvra Backend running on http://localhost:${PORT}`);
  
  // Start background price automation (Delhi Gold/Silver Scraper)
  priceService.initAutoUpdate().catch(err => {
    console.error('Failed to start price automation:', err.message);
  });
});
