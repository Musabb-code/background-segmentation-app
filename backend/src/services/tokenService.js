const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const env = require('../config/env');

const hashRefreshToken = (token) =>
  crypto.createHash('sha256').update(token).digest('hex');

const signAccessToken = (payload) =>
  jwt.sign(payload, env.JWT_SECRET, { expiresIn: env.JWT_ACCESS_EXPIRES });

const signRefreshToken = (payload) =>
  jwt.sign(
    { ...payload, jti: crypto.randomUUID() },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.JWT_REFRESH_EXPIRES },
  );

const verifyRefreshToken = (token) => jwt.verify(token, env.JWT_REFRESH_SECRET);

module.exports = {
  hashRefreshToken,
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
};
