const bcrypt = require('bcrypt');
const multer = require('multer');
const userRepository = require('../repositories/userRepository');
const sessionRepository = require('../repositories/sessionRepository');
const storageService = require('../services/storageService');
const tokenService = require('../services/tokenService');
const ApiError = require('../utils/ApiError');

const BCRYPT_ROUNDS = 12;
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_IMAGE_BYTES },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png'];
    if (allowed.includes(file.mimetype)) return cb(null, true);
    return cb(new ApiError(400, 'Profile image must be JPEG or PNG', 'VALIDATION_ERROR'));
  },
});

const getMe = async (req, res) => {
  const user = await userRepository.findById(req.user.userId);
  if (!user) {
    throw new ApiError(404, 'User not found', 'NOT_FOUND');
  }
  res.json(userRepository.toPublicUser(user));
};

const updateMe = async (req, res) => {
  const user = await userRepository.findById(req.user.userId);
  if (!user) {
    throw new ApiError(404, 'User not found', 'NOT_FOUND');
  }

  const fields = {};
  if (req.body.fullName !== undefined && req.body.fullName !== '') {
    if (req.body.fullName.length < 2) {
      throw new ApiError(400, 'Full name must be at least 2 characters', 'VALIDATION_ERROR');
    }
    fields.fullName = req.body.fullName;
  }

  if (req.file) {
    const url = await storageService.uploadProfileImage(
      req.user.userId,
      req.file.buffer,
      req.file.mimetype,
    );
    fields.profileImageUrl = url;
  }

  if (Object.keys(fields).length === 0) {
    throw new ApiError(400, 'No fields to update', 'VALIDATION_ERROR');
  }

  await userRepository.updateProfile(req.user.userId, fields);
  const updated = await userRepository.findById(req.user.userId);
  res.json(userRepository.toPublicUser(updated));
};

const changePassword = async (req, res) => {
  const { currentPassword, newPassword, refreshToken } = req.body;

  const user = await userRepository.findById(req.user.userId);
  if (!user) {
    throw new ApiError(404, 'User not found', 'NOT_FOUND');
  }

  const valid = await bcrypt.compare(currentPassword, user.password);
  if (!valid) {
    throw new ApiError(401, 'Current password is incorrect', 'UNAUTHORIZED');
  }

  const passwordHash = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);
  await userRepository.updatePassword(user.id, passwordHash);

  if (refreshToken) {
    const hash = tokenService.hashRefreshToken(refreshToken);
    const session = await sessionRepository.findByUserAndHash(user.id, hash);
    if (session) {
      await sessionRepository.deleteAllForUserExcept(user.id, session.id);
    } else {
      await sessionRepository.deleteAllForUser(user.id);
    }
  } else {
    await sessionRepository.deleteAllForUser(user.id);
  }

  res.json({ message: 'Password updated' });
};

module.exports = {
  getMe,
  updateMe,
  changePassword,
  upload,
};
