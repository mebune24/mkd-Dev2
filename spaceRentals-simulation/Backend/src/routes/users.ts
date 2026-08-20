import { Router } from 'express';
import { getUsers, submitKyc, getKycSubmissions } from '../controllers/userController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate, getUsers);
router.post('/kyc', authenticate, submitKyc);
router.get('/kyc', authenticate, getKycSubmissions);

export default router;
