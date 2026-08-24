import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import {
  getReportsSummary,
  getAdminTransactions,
  getAdminUsers,
  adminSuspendUser,
  adminActivateUser,
  getAdminProperties,
} from '../controllers/adminController';

const router = Router();

// All admin routes require authentication + admin role
router.use(authenticate, requireAdmin);

router.get('/reports/summary',    getReportsSummary);
router.get('/transactions',       getAdminTransactions);
router.get('/users',              getAdminUsers);
router.patch('/users/:id/suspend', adminSuspendUser);
router.patch('/users/:id/activate', adminActivateUser);
router.get('/properties',         getAdminProperties);

export default router;
