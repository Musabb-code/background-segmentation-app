const rateLimit = require('express-rate-limit');

const WINDOW_MS = 15 * 60 * 1000;

const rateLimitResponse = (req, res) => {
  res.status(429).json({
    success: false,
    message: 'Too many requests, please try again later',
    code: 'RATE_LIMITED',
    errors: [],
  });
};

const authLimiter = (max) =>
  rateLimit({
    windowMs: WINDOW_MS,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    handler: rateLimitResponse,
  });

const createAuthStrictLimiter = () => authLimiter(5);
const createAuthOtpLimiter = () => authLimiter(10);

const apiLimiter = authLimiter(100);

module.exports = {
  createAuthStrictLimiter,
  createAuthOtpLimiter,
  apiLimiter,
};
