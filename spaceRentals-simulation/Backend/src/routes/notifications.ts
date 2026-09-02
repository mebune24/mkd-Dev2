import { Router } from 'express';
import { authenticate } from '../middleware/authMiddleware';
import {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead,
  deleteNotification,
} from '../controllers/notificationController';

const router = Router();
router.use(authenticate);

router.get('/',            getMyNotifications);
router.patch('/read-all',  markAllNotificationsRead);
router.patch('/:id/read',  markNotificationRead);
router.delete('/:id',      deleteNotification);

export default router;
