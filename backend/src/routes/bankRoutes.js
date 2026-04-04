const express = require('express');
const router = express.Router();
const bankController = require('../controllers/bankController');
const authMiddleware = require('../middlewares/authMiddleware');

// All bank routes require authentication
router.use(authMiddleware);

/**
 * @route   POST /api/banks
 * @desc    Add a new bank account
 * @access  Private
 */
router.post('/', bankController.addBankAccount);

/**
 * @route   GET /api/banks
 * @desc    Get all bank accounts for the user
 * @access  Private
 */
router.get('/', bankController.getBankAccounts);

/**
 * @route   PATCH /api/banks/:id/primary
 * @desc    Set a bank account as primary
 * @access  Private
 */
router.patch('/:id/primary', bankController.setPrimaryAccount);

/**
 * @route   DELETE /api/banks/:id
 * @desc    Delete a bank account
 * @access  Private
 */
router.delete('/:id', bankController.deleteBankAccount);

module.exports = router;
