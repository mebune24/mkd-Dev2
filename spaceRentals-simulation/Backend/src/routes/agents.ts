import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
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
router.get('/profile', authenticate, getAgentProfile);

// KYC
router.get('/kyc/me',           authenticate, getMyKyc);
router.post('/kyc',             authenticate, submitKyc);
router.get('/kyc/pending',      authenticate, requireAdmin, getPendingKyc);
router.get('/kyc',              authenticate, requireAdmin, getAllKyc);
router.patch('/kyc/:id/approve', authenticate, requireAdmin, approveKyc);
router.patch('/kyc/:id/reject',  authenticate, requireAdmin, rejectKyc);

// Wallet
router.get('/wallet',              authenticate, getWallet);
router.post('/wallet/withdraw',    authenticate, requestWithdrawal);
router.get('/wallet/withdrawals',  authenticate, getWithdrawals);

// Commissions
router.get('/commissions',      authenticate, getMyCommissions);
router.get('/commissions/all',  authenticate, requireAdmin, getAllCommissions);

export default router;
