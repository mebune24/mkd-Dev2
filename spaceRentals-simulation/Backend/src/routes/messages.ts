import { Router } from 'express';
import { authenticate, requireLandlordVerificationIfApplicable } from '../middleware/authMiddleware';
import { getConversations, getRoomMessages, sendMessage, markRoomRead } from '../controllers/messageController';

const router = Router();
router.use(authenticate, requireLandlordVerificationIfApplicable);
router.get('/conversations', getConversations);
router.get('/:roomId', getRoomMessages);
router.post('/', sendMessage);
router.patch('/:roomId/read', markRoomRead);

export default router;
