import { Router } from 'express';
import {
  authenticate,
  requireAdmin,
  requireLandlordVerificationIfApplicable,
  requireVerifiedLandlord,
} from '../middleware/authMiddleware';
import {
  getLeaseById,
  getLeaseByApplicationId,
  getTenantLeases,
  getLandlordLeases,
  getAllLeases,
  acceptLease,
  rejectLease,
  signLease,
} from '../controllers/leaseController';

const router = Router();
router.use(authenticate, requireLandlordVerificationIfApplicable);

router.get('/tenant', getTenantLeases);
router.get('/landlord', requireVerifiedLandlord, getLandlordLeases);
router.get('/', requireAdmin, getAllLeases);
router.get('/by-application/:applicationId', getLeaseByApplicationId);
router.get('/:id', getLeaseById);
router.patch('/:id/accept', acceptLease);
router.patch('/:id/reject', rejectLease);
router.patch('/:id/sign', signLease);

export default router;
