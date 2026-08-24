import { Router } from 'express';
import { authenticate } from '../middleware/authMiddleware';
import {
  getTenantApplications,
  getLandlordApplications,
  submitApplication,
  approveApplication,
  rejectApplication,
  withdrawApplication,
} from '../controllers/applicationController';

const router = Router();

router.use(authenticate);

router.get('/tenant', getTenantApplications);
router.get('/landlord', getLandlordApplications);
router.post('/', submitApplication);
router.patch('/:id/approve', approveApplication);
router.patch('/:id/reject', rejectApplication);
router.patch('/:id/withdraw', withdrawApplication);

export default router;
