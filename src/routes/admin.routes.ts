import { Router } from 'express';
import { listNotifications, getNotificationById, getStatistics } from '../controllers/admin.controller.js';
import { authenticateAdminKey } from '../middleware/auth.middleware.js';

const router = Router();

router.use(authenticateAdminKey);

router.get('/notifications', listNotifications);
router.get('/notifications/stats', getStatistics);
router.get('/notifications/:id', getNotificationById);

export default router;
