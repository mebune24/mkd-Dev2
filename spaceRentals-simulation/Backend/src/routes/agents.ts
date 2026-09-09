import { Router } from 'express';
import {
  authenticate,
  requireAdmin,
  requireAgent,
  requireVerifiedAgent,
} from '../middleware/authMiddleware';
import {
  listAgents,
  getAgentProfile,
  getMyKyc,
  submitKyc,
  getAllKyc,
  getPendingKyc,
  approveKyc,
  rejectKyc,
  getWallet,
  requestWithdrawal,
  getWithdrawals,
  getMyCommissions,
  getAllCommissions,
} from '../controllers/agentController';

const router = Router();

// Public marketplace listing
router.get('/', listAgents);

// Agent profile (self)
router.get('/profile', authenticate, requireAgent, getAgentProfile);

// KYC
router.get('/kyc/me',           authenticate, requireAgent, getMyKyc);
router.post('/kyc',             authenticate, requireAgent, submitKyc);
router.get('/kyc/pending',      authenticate, requireAdmin, getPendingKyc);
router.get('/kyc',              authenticate, requireAdmin, getAllKyc);
router.patch('/kyc/:id/approve', authenticate, requireAdmin, approveKyc);
router.patch('/kyc/:id/reject',  authenticate, requireAdmin, rejectKyc);

// Wallet
router.get('/wallet',              authenticate, requireVerifiedAgent, getWallet);
router.post('/wallet/withdraw',    authenticate, requireVerifiedAgent, requestWithdrawal);
router.get('/wallet/withdrawals',  authenticate, requireVerifiedAgent, getWithdrawals);

// Commissions
router.get('/commissions',      authenticate, requireVerifiedAgent, getMyCommissions);
router.get('/commissions/all',  authenticate, requireAdmin, getAllCommissions);

export default router;
