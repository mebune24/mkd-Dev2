import { Router } from 'express';
import {
  authenticate,
  requireVerifiedLandlord,
} from '../middleware/authMiddleware';
import { getPlans, getStatus, initiateSubscription } from '../controllers/subscriptionController';

const router = Router();

router.get('/plans', getPlans);
router.get('/status', authenticate, requireVerifiedLandlord, getStatus);
router.post('/initiate', authenticate, requireVerifiedLandlord, initiateSubscription);

export default router;
