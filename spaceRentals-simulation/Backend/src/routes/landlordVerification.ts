import { Router } from 'express';
import { authenticate, requireAdmin, requireLandlord } from '../middleware/authMiddleware';
import {
  submit,
  getMy,
  getAll,
  approve,
  reject,
} from '../controllers/landlordVerificationController';

const router = Router();

router.post('/', authenticate, requireLandlord, submit);
router.get('/me', authenticate, requireLandlord, getMy);
router.get('/', authenticate, requireAdmin, getAll);
router.patch('/:id/approve', authenticate, requireAdmin, approve);
router.patch('/:id/reject', authenticate, requireAdmin, reject);

export default router;
