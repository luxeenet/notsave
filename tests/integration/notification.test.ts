import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../../src/app.js';
import { env } from '../../src/config/environment.js';

const app = createApp();

describe('Notification Receiver Auth & Security Integration', () => {
  it('rejects POST /api/v1/notifications without Authorization header with 401', async () => {
    const res = await request(app)
      .post('/api/v1/notifications')
      .send({
        packageName: 'com.android.settings',
        time: 1694825600000,
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Unauthorized');
  });

  it('rejects POST /api/v1/notifications with invalid Bearer token with 401', async () => {
    const res = await request(app)
      .post('/api/v1/notifications')
      .set('Authorization', 'Bearer INVALID_WRONG_TOKEN')
      .send({
        packageName: 'com.android.settings',
        time: 1694825600000,
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Unauthorized');
  });

  it('passes authentication with valid Bearer token but fails validation on empty payload', async () => {
    const res = await request(app)
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${env.BEARER_TOKEN}`)
      .send({});

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Invalid request payload');
  });
});
