jest.mock('../repositories/userRepository');
jest.mock('../repositories/otpRepository');
jest.mock('../services/emailService');
jest.mock('crypto', () => ({
  ...jest.requireActual('crypto'),
  randomInt: jest.fn(() => 123456),
}));

const request = require('supertest');
const app = require('../../server');
const userRepository = require('../repositories/userRepository');
const otpRepository = require('../repositories/otpRepository');
const emailService = require('../services/emailService');

describe('POST /api/auth/register', () => {
  beforeEach(() => {
    userRepository.findByEmail.mockResolvedValue(null);
    userRepository.create.mockResolvedValue({ id: 'user-1', email: 'jane@example.com' });
    otpRepository.create.mockResolvedValue({ id: 'otp-1' });
    emailService.sendOtpEmail.mockResolvedValue(undefined);
  });

  it('registers a new user', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ fullName: 'Jane Doe', email: 'jane@example.com', password: 'securePass1' });

    expect(res.status).toBe(201);
    expect(res.body.email).toBe('jane@example.com');
    expect(userRepository.create).toHaveBeenCalled();
    expect(emailService.sendOtpEmail).toHaveBeenCalled();
  });

  it('rejects duplicate email', async () => {
    userRepository.findByEmail.mockResolvedValue({ id: 'existing' });

    const res = await request(app)
      .post('/api/auth/register')
      .send({ fullName: 'Jane Doe', email: 'jane@example.com', password: 'securePass1' });

    expect(res.status).toBe(409);
    expect(res.body.code).toBe('CONFLICT');
  });

  it('rejects invalid input', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ fullName: 'J', email: 'bad', password: 'short' });

    expect(res.status).toBe(400);
    expect(res.body.code).toBe('VALIDATION_ERROR');
  });
});
