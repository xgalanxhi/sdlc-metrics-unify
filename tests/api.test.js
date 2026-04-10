const request = require('supertest');
const app = require('../src/index');

describe('API Endpoints', () => {
  describe('GET /health', () => {
    test('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe('GET /api/version', () => {
    test('should return version information', async () => {
      const response = await request(app).get('/api/version');
      expect(response.status).toBe(200);
      expect(response.body.version).toBeDefined();
      expect(response.body.environment).toBeDefined();
    });
  });

  describe('POST /api/metrics', () => {
    test('should calculate metrics for valid input', async () => {
      const response = await request(app)
        .post('/api/metrics')
        .send({ deployments: 100, failures: 5 });

      expect(response.status).toBe(200);
      expect(response.body.totalDeployments).toBe(100);
      expect(response.body.successRate).toBe(95.00);
      expect(response.body.failureRate).toBe(5.00);
    });

    test('should return 400 for invalid input', async () => {
      const response = await request(app)
        .post('/api/metrics')
        .send({ deployments: -1, failures: 0 });

      expect(response.status).toBe(400);
      expect(response.body.error).toBeDefined();
    });

    test('should return 400 when failures exceed deployments', async () => {
      const response = await request(app)
        .post('/api/metrics')
        .send({ deployments: 5, failures: 10 });

      expect(response.status).toBe(400);
    });
  });
});
