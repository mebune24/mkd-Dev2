import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import {
  getAdminOverview,
  getReportsSummary,
  getAdminTransactions,
  getAdminUsers,
  createAdminUser,
  bulkSuspendUsers,
  adminSuspendUser,
  adminActivateUser,
  getAdminProperties,
  getAdminPlatformFees,
  getAdminSubscriptions,
} from '../controllers/adminController';

const router = Router();

// All admin routes require authentication + admin role
router.use(authenticate, requireAdmin);

router.get('/reports/summary',    getReportsSummary);
router.get('/overview',            getAdminOverview);
router.get('/transactions',       getAdminTransactions);
router.get('/users',              getAdminUsers);
router.post('/users',              createAdminUser);
router.post('/users/bulk-suspend', bulkSuspendUsers);
router.patch('/users/:id/suspend', adminSuspendUser);
router.patch('/users/:id/activate', adminActivateUser);
router.get('/properties',         getAdminProperties);
router.get('/platform-fees',      getAdminPlatformFees);
router.get('/subscriptions',      getAdminSubscriptions);

export default router;
