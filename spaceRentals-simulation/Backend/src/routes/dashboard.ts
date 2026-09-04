import { Router } from 'express';
import { authenticate, requireLandlord } from '../middleware/authMiddleware';
import { getLandlordDashboardStats } from '../controllers/dashboardController';

import { cacheResponse } from '../middleware/cacheMiddleware';

const router = Router();

// Protected — Landlord
router.get('/landlord', authenticate, requireLandlord, cacheResponse(60), getLandlordDashboardStats);

export default router;
