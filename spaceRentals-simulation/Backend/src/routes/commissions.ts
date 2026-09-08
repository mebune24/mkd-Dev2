import { Router } from 'express';
import { commissionWebhook } from '../controllers/commissionController';
import { requestWithdrawal } from '../controllers/agentController';
import { authenticate, requireAgent } from '../middleware/authMiddleware';

const router = Router();

router.post('/withdraw', authenticate, requireAgent, requestWithdrawal);
router.post('/webhook', commissionWebhook); // called by payment provider; no auth header

export default router;
