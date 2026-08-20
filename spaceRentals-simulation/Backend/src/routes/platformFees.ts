import { Router } from 'express';
import { getPlatformFees, initiateFeePay, feePaymentWebhook } from '../controllers/platformFeeController';
import { authenticate, requireLandlord } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate, requireLandlord, getPlatformFees);
router.post('/:id/pay', authenticate, requireLandlord, initiateFeePay);
router.post('/webhook', feePaymentWebhook); // called by payment provider; no auth header

export default router;
