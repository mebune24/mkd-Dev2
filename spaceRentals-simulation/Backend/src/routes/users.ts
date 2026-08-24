import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import { getAllUsers, getUserById, suspendUser, activateUser, getProfile, updateProfile } from '../controllers/userController';

const router = Router();

router.get('/profile',      authenticate, getProfile);
router.patch('/profile',    authenticate, updateProfile);
router.get('/',             authenticate, requireAdmin, getAllUsers);
router.get('/:id',          authenticate, getUserById);
router.patch('/:id/suspend',  authenticate, requireAdmin, suspendUser);
router.patch('/:id/activate', authenticate, requireAdmin, activateUser);

export default router;
