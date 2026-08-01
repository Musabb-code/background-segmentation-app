const ApiError = require('../utils/ApiError');
const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      code: err.code,
      errors: err.errors,
    });
  }

  if (err.name === 'ValidationError' && err.isJoi) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      code: 'VALIDATION_ERROR',
      errors: err.details.map((d) => ({ field: d.path.join('.'), message: d.message })),
    });
  }

  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      success: false,
      message: 'Profile image must be 5MB or less',
      code: 'VALIDATION_ERROR',
      errors: [],
    });
  }

  logger.error(err.message, { stack: err.stack });
  return res.status(500).json({
    success: false,
    message: 'Internal server error',
    code: 'INTERNAL_ERROR',
    errors: [],
  });
};

module.exports = errorHandler;
