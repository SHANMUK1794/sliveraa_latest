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
const transactionRoutes = require('./src/routes/transactionRoutes');
const bankRoutes = require('./src/routes/bankRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const supportRoutes = require('./src/routes/supportRoutes');

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
app.use('/api/transactions', transactionRoutes);
app.use('/api/banks', bankRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/support', supportRoutes);

// Health Check
app.get('/health', async (req, res) => {
  try {
    const dbCheck = await prisma.$queryRaw`SELECT 1`;
    res.json({ 
      status: 'OK', 
      message: 'Silvra Backend is running', 
      database: 'Connected'
    });
  } catch (error) {
    console.error('Health Check - Database Error:', error.message);
    res.status(500).json({ 
      status: 'ERROR', 
      message: 'Silvra Backend is running, but database is unreachable', 
      database: 'Disconnected',
      details: error.message
    });
  }
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
