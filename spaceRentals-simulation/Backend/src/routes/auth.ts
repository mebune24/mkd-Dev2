import { Router } from 'express';
import { register, login, getMe, changePassword, requestPasswordReset, confirmPasswordReset } from '../controllers/authController';
import { authenticate } from '../middleware/authMiddleware';
import { validateRequest } from '../middleware/validateMiddleware';
import { registerSchema, loginSchema } from '../utils/schemas';

const router = Router();

router.post('/register', validateRequest(registerSchema), register);
router.post('/login', validateRequest(loginSchema), login);
router.get('/me', authenticate, getMe);
router.patch('/change-password', authenticate, changePassword);
router.post('/password-reset', requestPasswordReset);
router.post('/password-reset/confirm', confirmPasswordReset);

export default router;
