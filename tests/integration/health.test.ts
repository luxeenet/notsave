import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../../src/app.js';

const app = createApp();

describe('Health Endpoints Integration', () => {
  it('GET / returns root service online status', async () => {
    const res = await request(app).get('/');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.service).toBe('android-notification-receiver');
    expect(res.body.status).toBe('online');
  });

  it('GET /health/live returns process liveness status', async () => {
    const res = await request(app).get('/health/live');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.status).toBe('alive');
  });

  it('GET /health/ready returns 503 when database is not connected', async () => {
    const res = await request(app).get('/health/ready');
    expect(res.status).toBe(503);
    expect(res.body.success).toBe(false);
    expect(res.body.database).toBe('disconnected');
  });
});
