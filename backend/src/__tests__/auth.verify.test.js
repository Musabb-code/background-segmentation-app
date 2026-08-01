jest.mock('../repositories/userRepository');
jest.mock('../repositories/otpRepository');

const request = require('supertest');
const app = require('../../server');
const userRepository = require('../repositories/userRepository');
const otpRepository = require('../repositories/otpRepository');

describe('POST /api/auth/verify', () => {
  beforeEach(() => {
    userRepository.findByEmail.mockResolvedValue({ id: 'user-1', email: 'jane@example.com' });
    userRepository.setVerified.mockResolvedValue(undefined);
    otpRepository.deleteById.mockResolvedValue(undefined);
  });

  it('verifies email with valid OTP', async () => {
    otpRepository.findLatestByEmailAndType.mockResolvedValue({ id: 'otp-1', code: '123456' });
    otpRepository.isExpired.mockReturnValue(false);

    const res = await request(app)
      .post('/api/auth/verify')
      .send({ email: 'jane@example.com', code: '123456' });

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Email verified');
    expect(userRepository.setVerified).toHaveBeenCalledWith('user-1');
  });

  it('rejects expired OTP', async () => {
    otpRepository.findLatestByEmailAndType.mockResolvedValue({ id: 'otp-1', code: '123456' });
    otpRepository.isExpired.mockReturnValue(true);

    const res = await request(app)
      .post('/api/auth/verify')
      .send({ email: 'jane@example.com', code: '123456' });

    expect(res.status).toBe(400);
    expect(res.body.code).toBe('VALIDATION_ERROR');
  });

  it('rejects wrong code', async () => {
    otpRepository.findLatestByEmailAndType.mockResolvedValue({ id: 'otp-1', code: '999999' });
    otpRepository.isExpired.mockReturnValue(false);

    const res = await request(app)
      .post('/api/auth/verify')
      .send({ email: 'jane@example.com', code: '123456' });

    expect(res.status).toBe(400);
    expect(res.body.code).toBe('VALIDATION_ERROR');
  });
});
