const express = require('express');
const router = express.Router();
const supportController = require('../controllers/supportController');

// Chatbot functionality
router.post('/chat', supportController.getChatResponse);

module.exports = router;
