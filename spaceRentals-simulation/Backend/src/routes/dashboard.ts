import { Router } from 'express';
import {
  authenticate,
  requireVerifiedLandlord,
} from '../middleware/authMiddleware';
import { getLandlordDashboardStats } from '../controllers/dashboardController';

import { cacheResponse } from '../middleware/cacheMiddleware';

const router = Router();

// Protected — Landlord
router.get(
  '/landlord',
  authenticate,
  requireVerifiedLandlord,
  cacheResponse(60),
  getLandlordDashboardStats,
);

export default router;
