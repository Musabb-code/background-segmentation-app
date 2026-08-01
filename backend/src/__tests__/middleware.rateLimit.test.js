jest.mock('../repositories/userRepository');

const request = require('supertest');
const app = require('../../server');
const userRepository = require('../repositories/userRepository');

describe('auth rate limiter', () => {
  it('throttles login after 5 requests', async () => {
    userRepository.findByEmail.mockResolvedValue(null);
    const body = { email: 'jane@example.com', password: 'securePass1' };

    for (let i = 0; i < 5; i += 1) {
      const res = await request(app).post('/api/auth/login').send(body);
      expect(res.status).not.toBe(429);
    }

    const res = await request(app).post('/api/auth/login').send(body);
    expect(res.status).toBe(429);
    expect(res.body.code).toBe('RATE_LIMITED');
  });
});
