import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../../src/app.js';
import { env } from '../../src/config/environment.js';

const app = createApp();

describe('Mock End-to-End Workflow Verification', () => {
  it('GET /health/live verifies process is alive', async () => {
    const res = await request(app).get('/health/live');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.status).toBe('alive');
  });

  it('GET /health/ready returns 503 when DB is offline', async () => {
    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(503);
    expect(res.body.success).toBe(false);
    expect(res.body.database).toBe('disconnected');
  });

  it('POST /api/v1/notifications rejects unauthorized token with 401', async () => {
    const res = await request(app)
      .post('/api/v1/notifications')
      .set('Authorization', 'Bearer INVALID_TOKEN')
      .send({
        packageName: 'com.android.settings',
        time: 1694825600000,
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/v1/notifications rejects missing required package name with 400', async () => {
    const res = await request(app)
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${env.BEARER_TOKEN}`)
      .send({
        title: 'Title',
        time: 1694825600000,
      });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });
});
