import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/authMiddleware';
import { getMyRnlp, startInstalmentPayment } from '../controllers/rnlpController';

const router = Router();
router.use(authenticate, requireRole(['tenant']));
router.get('/me', getMyRnlp);
router.post('/instalments/:instalmentId/pay', startInstalmentPayment);

export default router;