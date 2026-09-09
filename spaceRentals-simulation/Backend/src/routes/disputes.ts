import { Router } from 'express';
import { getAllDisputes, getDisputeById, createDispute, resolveDispute, reviewDispute } from '../controllers/disputeController';
import { authenticate, requireAdmin, requireLandlordVerificationIfApplicable } from '../middleware/authMiddleware';

const router = Router();
router.use(authenticate, requireLandlordVerificationIfApplicable);

// All roles can get their disputes
router.get('/',    getAllDisputes);
router.get('/:id', getDisputeById);

// Tenants and Landlords can create disputes
router.post('/', createDispute);

// Only admins can resolve disputes
router.patch('/:id/resolve', requireAdmin, resolveDispute);
router.patch('/:id/review', requireAdmin, reviewDispute);

export default router;
