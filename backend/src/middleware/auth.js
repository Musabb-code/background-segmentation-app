const jwt = require('jsonwebtoken');
const env = require('../config/env');
const ApiError = require('../utils/ApiError');

const auth = (req, res, next) => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return next(new ApiError(401, 'Unauthorized', 'UNAUTHORIZED'));
  }
  try {
    req.user = jwt.verify(header.slice(7), env.JWT_SECRET);
    return next();
  } catch {
    return next(new ApiError(401, 'Unauthorized', 'UNAUTHORIZED'));
  }
};

module.exports = auth;
