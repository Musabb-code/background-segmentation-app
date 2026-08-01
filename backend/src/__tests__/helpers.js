const bcrypt = require('bcrypt');

const TEST_PASSWORD = 'securePass1';

const buildUser = async (overrides = {}) => ({
  id: 'user-1',
  fullName: 'Jane Doe',
  email: 'jane@example.com',
  password: await bcrypt.hash(TEST_PASSWORD, 12),
  isVerified: true,
  profileImageUrl: null,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  ...overrides,
});

module.exports = { TEST_PASSWORD, buildUser };
