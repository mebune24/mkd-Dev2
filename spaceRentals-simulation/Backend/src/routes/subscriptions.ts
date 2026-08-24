import { Router } from 'express';
import { authenticate, requireLandlord } from '../middleware/authMiddleware';
import { getPlans, getStatus, initiateSubscription } from '../controllers/subscriptionController';

const router = Router();

router.get('/plans',    getPlans);
router.get('/status',   authenticate, requireLandlord, getStatus);
router.post('/initiate', authenticate, requireLandlord, initiateSubscription);

export default router;
