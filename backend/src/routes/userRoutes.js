const express = require('express');
const userController = require('../controllers/userController');
const asyncHandler = require('../utils/asyncHandler');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { changePasswordSchema } = require('../validators/userValidators');

const router = express.Router();

router.use(auth);

router.get('/me', asyncHandler(userController.getMe));
router.put('/me', userController.upload.single('profileImage'), asyncHandler(userController.updateMe));
router.put(
  '/me/password',
  validate(changePasswordSchema),
  asyncHandler(userController.changePassword),
);

module.exports = router;
