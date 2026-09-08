import { Router } from 'express';
import { getAllDisputes, getDisputeById, createDispute, resolveDispute, reviewDispute } from '../controllers/disputeController';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';

const router = Router();

// All roles can get their disputes
router.get('/',    authenticate, getAllDisputes);
router.get('/:id', authenticate, getDisputeById);

// Tenants and Landlords can create disputes
router.post('/', authenticate, createDispute);

// Only admins can resolve disputes
router.patch('/:id/resolve', authenticate, requireAdmin, resolveDispute);
router.patch('/:id/review', authenticate, requireAdmin, reviewDispute);

export default router;
