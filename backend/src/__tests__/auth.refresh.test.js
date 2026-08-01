jest.mock('../repositories/sessionRepository');

const request = require('supertest');
const app = require('../../server');
const sessionRepository = require('../repositories/sessionRepository');
const tokenService = require('../services/tokenService');

describe('POST /api/auth/refresh', () => {
  const payload = { userId: 'user-1', email: 'jane@example.com' };

  beforeEach(() => {
    sessionRepository.deleteById.mockResolvedValue(undefined);
    sessionRepository.create.mockResolvedValue({ id: 'session-2' });
  });

  it('rotates refresh token', async () => {
    const refreshToken = tokenService.signRefreshToken(payload);
    const hash = tokenService.hashRefreshToken(refreshToken);
    sessionRepository.findByUserAndHash.mockResolvedValue({
      id: 'session-1',
      userId: payload.userId,
      refreshTokenHash: hash,
    });
    sessionRepository.isExpired.mockReturnValue(false);

    const res = await request(app)
      .post('/api/auth/refresh')
      .send({ refreshToken });

    expect(res.status).toBe(200);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    expect(res.body.refreshToken).not.toBe(refreshToken);
    expect(sessionRepository.deleteById).toHaveBeenCalledWith('session-1');
    expect(sessionRepository.create).toHaveBeenCalled();
  });

  it('rejects expired session', async () => {
    const refreshToken = tokenService.signRefreshToken(payload);
    const hash = tokenService.hashRefreshToken(refreshToken);
    sessionRepository.findByUserAndHash.mockResolvedValue({
      id: 'session-1',
      userId: payload.userId,
      refreshTokenHash: hash,
    });
    sessionRepository.isExpired.mockReturnValue(true);

    const res = await request(app)
      .post('/api/auth/refresh')
      .send({ refreshToken });

    expect(res.status).toBe(401);
    expect(res.body.code).toBe('UNAUTHORIZED');
  });
});
