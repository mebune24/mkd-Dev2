import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/authMiddleware';
import {
  initiatePayment,
  initiatePayout,
  getPaymentStatus,
  getMyTransactions,
  fapshiWebhook,
} from '../controllers/paymentController';
import { validateRequest } from '../middleware/validateMiddleware';
import { initiatePaymentSchema } from '../utils/schemas';

const router = Router();

// Fapshi webhook — no auth (called server-to-server by Fapshi)
router.post('/webhook', fapshiWebhook);

// All other payment routes require authentication
router.use(authenticate);

router.post('/initiate', requireRole(['tenant', 'landlord', 'agent', 'admin']), validateRequest(initiatePaymentSchema), initiatePayment);
router.post('/payout', requireRole(['landlord', 'agent', 'admin']), initiatePayout);
router.get('/status/:gatewayTxId', getPaymentStatus);
router.get('/transactions', getMyTransactions);

export default router;
