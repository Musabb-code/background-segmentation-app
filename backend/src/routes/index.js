const express = require('express');
const asyncHandler = require('../utils/asyncHandler');
const { apiLimiter } = require('../middleware/rateLimiter');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');

const router = express.Router();

router.get(
  '/health',
  apiLimiter,
  asyncHandler(async (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  }),
);

router.use('/auth', authRoutes);
router.use('/users', apiLimiter, userRoutes);

module.exports = router;
