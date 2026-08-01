const Joi = require('joi');
const { password } = require('./authValidators');

const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: password.required(),
  refreshToken: Joi.string().optional(),
});

module.exports = { changePasswordSchema };
