jest.mock('../repositories/userRepository');

const request = require('supertest');
const app = require('../../server');
const userRepository = require('../repositories/userRepository');
const tokenService = require('../services/tokenService');
const { buildUser } = require('./helpers');

describe('GET /api/users/me', () => {
  beforeEach(() => {
  });

  it('returns profile for authenticated user', async () => {
    const user = await buildUser();
    userRepository.findById.mockResolvedValue(user);
    userRepository.toPublicUser.mockReturnValue({
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      isVerified: true,
      profileImageUrl: null,
      createdAt: user.createdAt,
    });

    const accessToken = tokenService.signAccessToken({ userId: user.id, email: user.email });

    const res = await request(app)
      .get('/api/users/me')
      .set('Authorization', `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.email).toBe(user.email);
  });

  it('returns 401 without token', async () => {
    const res = await request(app).get('/api/users/me');

    expect(res.status).toBe(401);
    expect(res.body.code).toBe('UNAUTHORIZED');
  });
});
