const express = require('express');
const authController = require('../controllers/authController');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const auth = require('../middleware/auth');
const {
  registerSchema,
  verifySchema,
  loginSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  refreshSchema,
  logoutSchema,
} = require('../validators/authValidators');
const {
  createAuthStrictLimiter,
  createAuthOtpLimiter,
  apiLimiter,
} = require('../middleware/rateLimiter');

const router = express.Router();

router.post('/register', createAuthStrictLimiter(), validate(registerSchema), asyncHandler(authController.register));
router.post('/verify', createAuthOtpLimiter(), validate(verifySchema), asyncHandler(authController.verify));
router.post('/login', createAuthStrictLimiter(), validate(loginSchema), asyncHandler(authController.login));
router.post('/forgot-password', createAuthStrictLimiter(), validate(forgotPasswordSchema), asyncHandler(authController.forgotPassword));
router.post('/reset-password', createAuthOtpLimiter(), validate(resetPasswordSchema), asyncHandler(authController.resetPassword));
router.post('/refresh', apiLimiter, validate(refreshSchema), asyncHandler(authController.refresh));
router.post('/logout', apiLimiter, auth, validate(logoutSchema), asyncHandler(authController.logout));

module.exports = router;
