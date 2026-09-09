import { Router } from 'express';
import { getPlatformFees, initiateFeePay, feePaymentWebhook } from '../controllers/platformFeeController';
import {
  authenticate,
  requireVerifiedLandlord,
} from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate, requireVerifiedLandlord, getPlatformFees);
router.post('/:id/pay', authenticate, requireVerifiedLandlord, initiateFeePay);
router.post('/webhook', feePaymentWebhook); // called by payment provider; no auth header

export default router;
