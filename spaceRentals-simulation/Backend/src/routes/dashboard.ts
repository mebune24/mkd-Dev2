import { Router } from 'express';
import { authenticate, requireLandlord } from '../middleware/authMiddleware';
import { getLandlordDashboardStats } from '../controllers/dashboardController';

const router = Router();

// Protected — Landlord
router.get('/landlord', authenticate, requireLandlord, getLandlordDashboardStats);

export default router;
