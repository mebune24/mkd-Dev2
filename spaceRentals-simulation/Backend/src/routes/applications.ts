import { Router } from 'express';
import {
  getApplications,
  getApplicationById,
  createApplication,
  updateApplicationStatus,
} from '../controllers/applicationController';
import { authenticate, requireTenant } from '../middleware/authMiddleware';

const router = Router();

router.get('/',    authenticate, getApplications);
router.get('/:id', authenticate, getApplicationById);
router.post('/',  authenticate, requireTenant, createApplication);

// Generic status update (used by admin and advanced clients)
router.patch('/:id/status', authenticate, updateApplicationStatus);

// Convenience action routes (Flutter calls these with no body needed)
router.post('/:id/approve',  authenticate, (req, res, next) => {
  (req as any).body = { ...(req as any).body, status: 'approved' };
  return updateApplicationStatus(req as any, res);
});
router.post('/:id/reject',   authenticate, (req, res, next) => {
  (req as any).body = { ...(req as any).body, status: 'rejected' };
  return updateApplicationStatus(req as any, res);
});
router.post('/:id/withdraw', authenticate, (req, res, next) => {
  (req as any).body = { ...(req as any).body, status: 'withdrawn' };
  return updateApplicationStatus(req as any, res);
});

export default router;
