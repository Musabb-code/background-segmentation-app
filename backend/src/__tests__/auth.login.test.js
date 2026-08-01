jest.mock('../repositories/userRepository');
jest.mock('../repositories/sessionRepository');

const request = require('supertest');
const app = require('../../server');
const userRepository = require('../repositories/userRepository');
const sessionRepository = require('../repositories/sessionRepository');
const { TEST_PASSWORD, buildUser } = require('./helpers');

describe('POST /api/auth/login', () => {
  beforeEach(() => {
    sessionRepository.create.mockResolvedValue({ id: 'session-1' });
  });

  it('logs in verified user', async () => {
    const user = await buildUser();
    userRepository.findByEmail.mockResolvedValue(user);
    userRepository.toPublicUser.mockReturnValue({
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      isVerified: true,
      profileImageUrl: null,
    });

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: TEST_PASSWORD });

    expect(res.status).toBe(200);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    expect(sessionRepository.create).toHaveBeenCalled();
  });

  it('rejects wrong password', async () => {
    const user = await buildUser();
    userRepository.findByEmail.mockResolvedValue(user);

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: 'wrongPass1' });

    expect(res.status).toBe(401);
    expect(res.body.code).toBe('UNAUTHORIZED');
  });

  it('rejects unverified user', async () => {
    const user = await buildUser({ isVerified: false });
    userRepository.findByEmail.mockResolvedValue(user);

    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: TEST_PASSWORD });

    expect(res.status).toBe(403);
    expect(res.body.code).toBe('EMAIL_NOT_VERIFIED');
  });
});
