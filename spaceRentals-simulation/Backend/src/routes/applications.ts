import { Router } from 'express';
import { authenticate, requireLandlordVerificationIfApplicable, requireVerifiedLandlord } from '../middleware/authMiddleware';
import {
  getTenantApplications,
  getApplicationById,
  getLandlordApplications,
  submitApplication,
  approveApplication,
  rejectApplication,
  withdrawApplication,
} from '../controllers/applicationController';

const router = Router();

router.use(authenticate, requireLandlordVerificationIfApplicable);

router.get('/tenant', getTenantApplications);
router.get('/landlord', requireVerifiedLandlord, getLandlordApplications);
router.get('/:id', getApplicationById);
router.post('/', submitApplication);
router.patch('/:id/approve', requireVerifiedLandlord, approveApplication);
router.patch('/:id/reject', requireVerifiedLandlord, rejectApplication);
router.patch('/:id/withdraw', withdrawApplication);

export default router;
