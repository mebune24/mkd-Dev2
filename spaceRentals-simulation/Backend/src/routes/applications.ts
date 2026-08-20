import { Router } from 'express';
import {
  getApplications,
  getApplicationById,
  createApplication,
  updateApplicationStatus,
} from '../controllers/applicationController';
import { authenticate, requireTenant } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate, getApplications);
router.get('/:id', authenticate, getApplicationById);
router.post('/', authenticate, requireTenant, createApplication);
router.patch('/:id/status', authenticate, updateApplicationStatus);

export default router;
