const nodemailer = require('nodemailer');
const env = require('../config/env');
const logger = require('../utils/logger');
const ApiError = require('../utils/ApiError');

let transporter;

const getTransporter = () => {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: env.SMTP_HOST,
      port: env.SMTP_PORT,
      auth: env.SMTP_USER ? { user: env.SMTP_USER, pass: env.SMTP_PASS } : undefined,
    });
  }
  return transporter;
};

const sendOtpEmail = async (email, code, type) => {
  const subject = type === 'register' ? 'Verify your email' : 'Reset your password';
  const text = `Your verification code is ${code}. It expires in 10 minutes.`;

  if (!env.SMTP_USER) {
    logger.info(`[dev OTP] ${email} (${type}): ${code}`);
    return;
  }

  try {
    await getTransporter().sendMail({
      from: env.EMAIL_FROM,
      to: email,
      subject,
      text,
    });
  } catch (err) {
    logger.error('Email send failed', { err: err.message });
    throw new ApiError(500, 'Failed to send email', 'INTERNAL_ERROR');
  }
};

module.exports = { sendOtpEmail };
