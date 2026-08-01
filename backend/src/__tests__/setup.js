process.env.NODE_ENV = 'test';
process.env.CLIENT_URL = 'http://localhost';
process.env.JWT_SECRET = 'test-jwt-secret-minimum-32-characters!!';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-min-32-chars!!';
process.env.FIREBASE_PROJECT_ID = 'test-project';
process.env.FIREBASE_CLIENT_EMAIL = 'admin@test.com';
process.env.FIREBASE_PRIVATE_KEY = 'fake-key';
process.env.FIREBASE_STORAGE_BUCKET = 'test.appspot.com';
process.env.SMTP_USER = '';

// Repos call admin.firestore() at import; automocks still load real modules.
jest.mock('../config/firebase', () => {
  const firestore = Object.assign(
    jest.fn(() => ({
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({ get: jest.fn(), set: jest.fn(), update: jest.fn(), delete: jest.fn() })),
        where: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        get: jest.fn(),
        add: jest.fn(),
      })),
    })),
    {
      FieldValue: { serverTimestamp: jest.fn(() => 'ts') },
      Timestamp: { fromDate: (d) => d },
    },
  );
  return {
    firestore,
    storage: jest.fn(() => ({
      bucket: jest.fn(() => ({
        name: 'test.appspot.com',
        file: jest.fn(() => ({
          save: jest.fn(),
          makePublic: jest.fn(),
        })),
      })),
    })),
  };
});
