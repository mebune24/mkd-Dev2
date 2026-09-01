import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import { getLeaseById, getLeaseByApplicationId, getTenantLeases, getLandlordLeases, getAllLeases, signLease } from '../controllers/leaseController';

const router = Router();

router.get('/tenant',   authenticate, getTenantLeases);
router.get('/landlord', authenticate, getLandlordLeases);
router.get('/',         authenticate, requireAdmin, getAllLeases);
router.get('/by-application/:applicationId', authenticate, getLeaseByApplicationId);
router.get('/:id',      authenticate, getLeaseById);
router.patch('/:id/sign', authenticate, signLease);

export default router;
