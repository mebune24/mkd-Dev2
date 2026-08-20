import { Router } from 'express';
import {
  getUsers,
  updateUserStatus,
  submitAgentKyc,
  getAgentKycSubmissions,
  reviewAgentKyc,
  getAgentWallet,
} from '../controllers/userController';
import { authenticate, requireAdmin, requireAgent } from '../middleware/authMiddleware';

const router = Router();

// Admin only
router.get('/', authenticate, requireAdmin, getUsers);
router.patch('/:id/status', authenticate, requireAdmin, updateUserStatus);
router.get('/kyc/agents', authenticate, requireAdmin, getAgentKycSubmissions);
router.patch('/kyc/agents/:id', authenticate, requireAdmin, reviewAgentKyc);

// Agent only
router.post('/kyc/agent', authenticate, requireAgent, submitAgentKyc);
router.get('/wallet', authenticate, requireAgent, getAgentWallet);

export default router;
