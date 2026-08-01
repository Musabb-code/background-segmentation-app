const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, { abortEarly: false });
  if (error) {
    error.isJoi = true;
    return next(error);
  }
  req.body = value;
  return next();
};

module.exports = validate;
