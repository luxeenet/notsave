import { Router } from 'express';
import { receiveNotification } from '../controllers/notification.controller.js';
import { listNotifications, getStatistics } from '../controllers/admin.controller.js';
import { authenticateBearerToken } from '../middleware/auth.middleware.js';
import { validateBody } from '../middleware/validation.middleware.js';
import { notificationPayloadSchema } from '../validators/notification.validator.js';
import { notificationRateLimiter } from '../middleware/rateLimit.middleware.js';

const router = Router();

router.post(
  '/notifications',
  notificationRateLimiter,
  authenticateBearerToken,
  validateBody(notificationPayloadSchema),
  receiveNotification
);

router.get(
  '/notifications',
  notificationRateLimiter,
  authenticateBearerToken,
  listNotifications
);

router.get(
  '/notifications/stats',
  notificationRateLimiter,
  authenticateBearerToken,
  getStatistics
);

export default router;
