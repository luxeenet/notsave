import { describe, it, expect } from 'vitest';
import { notificationPayloadSchema } from '../../src/validators/notification.validator.js';

describe('Notification Validator', () => {
  it('validates a complete valid notification payload', () => {
    const payload = {
      id: 'test-hash-001',
      packageName: 'com.android.settings',
      key: '0|com.android.settings|1001',
      title: 'Update Notification',
      text: 'Download available',
      subText: 'System',
      bigText: 'Detailed expanded notification content',
      category: 'msg',
      time: 1694825600000,
    };

    const parsed = notificationPayloadSchema.safeParse(payload);
    expect(parsed.success).toBe(true);
  });

  it('accepts valid payload with missing optional fields', () => {
    const payload = {
      packageName: 'com.example.app',
      time: 1694825600000,
    };

    const parsed = notificationPayloadSchema.safeParse(payload);
    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.packageName).toBe('com.example.app');
      expect(parsed.data.title).toBeUndefined();
    }
  });

  it('rejects payload missing required packageName', () => {
    const payload = {
      title: 'Missing Package',
      time: 1694825600000,
    };

    const parsed = notificationPayloadSchema.safeParse(payload);
    expect(parsed.success).toBe(false);
  });

  it('coerces string timestamp into numeric time', () => {
    const payload = {
      packageName: 'com.test',
      time: '1694825600000',
    };

    const parsed = notificationPayloadSchema.safeParse(payload);
    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.time).toBe(1694825600000);
    }
  });
});
