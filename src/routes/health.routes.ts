import { Router } from 'express';
import { getRootHealth, getLiveness, getReadiness } from '../controllers/health.controller.js';

const router = Router();

router.get('/', getRootHealth);
router.get('/health/live', getLiveness);
router.get('/health/ready', getReadiness);

export default router;
