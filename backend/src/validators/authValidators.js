const Joi = require('joi');

const password = Joi.string()
  .min(8)
  .pattern(/[A-Z]/)
  .pattern(/[0-9]/)
  .messages({
    'string.min': 'Password must be at least 8 characters',
    'string.pattern.base': 'Password must contain at least one uppercase letter and one number',
  });

const refreshTokenBody = Joi.object({
  refreshToken: Joi.string().required(),
});

module.exports = {
  password,
  registerSchema: Joi.object({
    fullName: Joi.string().min(2).required(),
    email: Joi.string().email().required(),
    password: password.required(),
  }),
  verifySchema: Joi.object({
    email: Joi.string().email().required(),
    code: Joi.string().length(6).pattern(/^\d+$/).required(),
  }),
  loginSchema: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required(),
  }),
  forgotPasswordSchema: Joi.object({
    email: Joi.string().email().required(),
  }),
  resetPasswordSchema: Joi.object({
    email: Joi.string().email().required(),
    code: Joi.string().length(6).pattern(/^\d+$/).required(),
    newPassword: password.required(),
  }),
  refreshSchema: refreshTokenBody,
  logoutSchema: refreshTokenBody,
};
