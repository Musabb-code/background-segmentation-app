const Joi = require('joi');

const unlessAdc = (schema) =>
  schema.empty('').when('GOOGLE_APPLICATION_CREDENTIALS', {
    is: Joi.string().min(1).required(),
    then: Joi.optional(),
    otherwise: Joi.required(),
  });

const schema = Joi.object({
  PORT: Joi.number().default(3000),
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  CLIENT_URL: Joi.string().uri().required(),
  GOOGLE_APPLICATION_CREDENTIALS: Joi.string().empty('').optional(),
  FIREBASE_PROJECT_ID: unlessAdc(Joi.string()),
  FIREBASE_CLIENT_EMAIL: unlessAdc(Joi.string().email()),
  FIREBASE_PRIVATE_KEY: unlessAdc(Joi.string()),
  FIREBASE_STORAGE_BUCKET: unlessAdc(Joi.string()),
  JWT_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_EXPIRES: Joi.string().default('15m'),
  JWT_REFRESH_EXPIRES: Joi.string().default('7d'),
  SMTP_HOST: Joi.string().default('smtp.gmail.com'),
  SMTP_PORT: Joi.number().default(587),
  SMTP_USER: Joi.string().allow('').default(''),
  SMTP_PASS: Joi.string().allow('').default(''),
  EMAIL_FROM: Joi.string().default('Real-Time BG Removal <noreply@example.com>'),
  ML_SERVICE_URL: Joi.string().uri().default('http://localhost:8000'),
}).unknown(true);

const { error, value } = schema.validate(process.env, {
  abortEarly: false,
});

if (error) {
  throw new Error(`Env validation failed:\n${error.details.map((d) => d.message).join('\n')}`);
}

module.exports = {
  ...value,
  FIREBASE_PRIVATE_KEY: value.FIREBASE_PRIVATE_KEY
    ? value.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
    : undefined,
};
