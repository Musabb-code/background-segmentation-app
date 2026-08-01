const bcrypt = require('bcrypt');
const crypto = require('crypto');
const userRepository = require('../repositories/userRepository');
const otpRepository = require('../repositories/otpRepository');
const sessionRepository = require('../repositories/sessionRepository');
const tokenService = require('../services/tokenService');
const emailService = require('../services/emailService');
const ApiError = require('../utils/ApiError');

const BCRYPT_ROUNDS = 12;

const generateCode = () => crypto.randomInt(100000, 999999).toString();

const register = async (req, res) => {
  const { fullName, email, password } = req.body;

  const existing = await userRepository.findByEmail(email);
  if (existing) {
    throw new ApiError(409, 'Email already registered', 'CONFLICT');
  }

  const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  await userRepository.create({ fullName, email, passwordHash });

  const code = generateCode();
  await otpRepository.create({ email, code, type: 'register' });
  await emailService.sendOtpEmail(email, code, 'register');

  res.status(201).json({ message: 'Registration successful. Check your email for verification code.', email });
};

const verify = async (req, res) => {
  const { email, code } = req.body;

  const otp = await otpRepository.findLatestByEmailAndType(email, 'register');
  if (!otp || otp.code !== code || otpRepository.isExpired(otp)) {
    throw new ApiError(400, 'Invalid or expired verification code', 'VALIDATION_ERROR');
  }

  const user = await userRepository.findByEmail(email);
  if (!user) {
    throw new ApiError(404, 'User not found', 'NOT_FOUND');
  }

  await userRepository.setVerified(user.id);
  await otpRepository.deleteById(otp.id);

  res.json({ message: 'Email verified' });
};

const login = async (req, res) => {
  const { email, password } = req.body;

  const user = await userRepository.findByEmail(email);
  if (!user) {
    throw new ApiError(401, 'Invalid email or password', 'UNAUTHORIZED');
  }

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) {
    throw new ApiError(401, 'Invalid email or password', 'UNAUTHORIZED');
  }

  if (!user.isVerified) {
    throw new ApiError(403, 'Email not verified', 'EMAIL_NOT_VERIFIED');
  }

  const payload = { userId: user.id, email: user.email };
  const accessToken = tokenService.signAccessToken(payload);
  const refreshToken = tokenService.signRefreshToken(payload);
  const refreshTokenHash = tokenService.hashRefreshToken(refreshToken);

  await sessionRepository.create({
    userId: user.id,
    refreshTokenHash,
    deviceInfo: req.headers['user-agent'],
  });

  res.json({
    accessToken,
    refreshToken,
    user: userRepository.toPublicUser(user),
  });
};

const forgotPassword = async (req, res) => {
  const { email } = req.body;

  const user = await userRepository.findByEmail(email);
  if (user) {
    const code = generateCode();
    await otpRepository.create({ email, code, type: 'reset' });
    await emailService.sendOtpEmail(email, code, 'reset');
  }

  res.json({ message: 'If that email exists, a reset code has been sent.' });
};

const resetPassword = async (req, res) => {
  const { email, code, newPassword } = req.body;

  const otp = await otpRepository.findLatestByEmailAndType(email, 'reset');
  if (!otp || otp.code !== code || otpRepository.isExpired(otp)) {
    throw new ApiError(400, 'Invalid or expired verification code', 'VALIDATION_ERROR');
  }

  const user = await userRepository.findByEmail(email);
  if (!user) {
    throw new ApiError(404, 'User not found', 'NOT_FOUND');
  }

  const passwordHash = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);
  await userRepository.updatePassword(user.id, passwordHash);
  await otpRepository.deleteById(otp.id);
  await sessionRepository.deleteAllForUser(user.id);

  res.json({ message: 'Password reset successful' });
};

const refresh = async (req, res) => {
  const { refreshToken } = req.body;

  let payload;
  try {
    payload = tokenService.verifyRefreshToken(refreshToken);
  } catch {
    throw new ApiError(401, 'Invalid refresh token', 'UNAUTHORIZED');
  }

  const refreshTokenHash = tokenService.hashRefreshToken(refreshToken);
  const session = await sessionRepository.findByUserAndHash(payload.userId, refreshTokenHash);

  if (!session || sessionRepository.isExpired(session)) {
    throw new ApiError(401, 'Invalid or expired session', 'UNAUTHORIZED');
  }

  await sessionRepository.deleteById(session.id);

  const newPayload = { userId: payload.userId, email: payload.email };
  const accessToken = tokenService.signAccessToken(newPayload);
  const newRefreshToken = tokenService.signRefreshToken(newPayload);
  const newHash = tokenService.hashRefreshToken(newRefreshToken);

  await sessionRepository.create({
    userId: payload.userId,
    refreshTokenHash: newHash,
    deviceInfo: req.headers['user-agent'],
  });

  res.json({ accessToken, refreshToken: newRefreshToken });
};

const logout = async (req, res) => {
  const { refreshToken } = req.body;
  const refreshTokenHash = tokenService.hashRefreshToken(refreshToken);
  const session = await sessionRepository.findByUserAndHash(req.user.userId, refreshTokenHash);

  if (session) {
    await sessionRepository.deleteById(session.id);
  }

  res.json({ message: 'Logged out' });
};

module.exports = {
  register,
  verify,
  login,
  forgotPassword,
  resetPassword,
  refresh,
  logout,
};
