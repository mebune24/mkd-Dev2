import { Router } from 'express';
import { authenticate, requireAdmin, requireAgent } from '../middleware/authMiddleware';
import { getAllUsers, getUserById, suspendUser, activateUser } from '../controllers/userController';

const router = Router();

router.get('/', authenticate, requireAdmin, getAllUsers);
router.get('/:id', authenticate, getUserById);
router.patch('/:id/suspend', authenticate, requireAdmin, suspendUser);
router.patch('/:id/activate', authenticate, requireAdmin, activateUser);

export default router;
