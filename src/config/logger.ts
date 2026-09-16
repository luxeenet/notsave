import pino from 'pino';
import { env } from './environment.js';

export const logger = pino({
  level: env.LOG_LEVEL,
  base: {
    env: env.NODE_ENV,
    service: 'android-notification-receiver',
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level(label) {
      return { level: label };
    },
  },
  redact: {
    paths: [
      'req.headers.authorization',
      'headers.authorization',
      'authorization',
      'bearerToken',
      'token',
      'ADMIN_API_KEY',
      'BEARER_TOKEN',
    ],
    remove: true,
  },
});
