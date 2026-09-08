import { Router } from 'express';
import { authenticate, requireAdmin, optionalAuthenticate } from '../middleware/authMiddleware';
import { getAllUsers, getUserById, suspendUser, activateUser, getProfile, updateProfile } from '../controllers/userController';
import { followUser, unfollowUser, getFollowStatus, getPublicProfile } from '../controllers/followController';

const router = Router();

router.get('/profile',              authenticate, getProfile);
router.patch('/profile',            authenticate, updateProfile);
router.get('/',                     authenticate, requireAdmin, getAllUsers);
router.get('/:id/public-profile',   optionalAuthenticate, getPublicProfile);
router.get('/:id/follow-status',    authenticate, getFollowStatus);
router.post('/:id/follow',          authenticate, followUser);
router.delete('/:id/follow',        authenticate, unfollowUser);
router.get('/:id',                  authenticate, getUserById);
router.patch('/:id/suspend',        authenticate, requireAdmin, suspendUser);
router.patch('/:id/activate',       authenticate, requireAdmin, activateUser);

export default router;
