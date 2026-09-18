import { Router } from 'express';
import {
  authenticate,
  requireVerifiedLandlord,
} from '../middleware/authMiddleware';
import { getLandlordDashboardStats } from '../controllers/dashboardController';


const router = Router();

// Protected — Landlord
router.get(
  '/landlord',
  authenticate,
  requireVerifiedLandlord,
  getLandlordDashboardStats,
);

export default router;
