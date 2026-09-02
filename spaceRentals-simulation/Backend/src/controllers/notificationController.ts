import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

// GET /api/notifications — list notifications for current user
export const getMyNotifications = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const { limit = '20', page = '1', unreadOnly } = req.query;
    const take = Math.min(parseInt(limit as string), 50);
    const skip = (parseInt(page as string) - 1) * take;
    const where: any = { userId };
    if (unreadOnly === 'true') where.isRead = false;

    const [notifications, total, unreadCount] = await Promise.all([
      prisma.notification.findMany({ where, skip, take, orderBy: { createdAt: 'desc' } }),
      prisma.notification.count({ where }),
      prisma.notification.count({ where: { userId, isRead: false } }),
    ]);

    res.json({ data: notifications, total, page: parseInt(page as string), limit: take, unreadCount });
  } catch (e) {
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

// PATCH /api/notifications/read-all
export const markAllNotificationsRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const { count } = await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    res.json({ message: `Marked ${count} notifications as read` });
  } catch (e) {
    res.status(500).json({ message: 'Failed to mark all notifications as read' });
  }
};

// PATCH /api/notifications/:id/read
export const markNotificationRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const id = req.params.id as string;
    const notification = await prisma.notification.findFirst({ where: { id, userId } });
    if (!notification) return res.status(404).json({ message: 'Notification not found' }) as any;
    const updated = await prisma.notification.update({ where: { id }, data: { isRead: true } });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: 'Failed to mark notification as read' });
  }
};

// DELETE /api/notifications/:id
export const deleteNotification = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.userId;
    const id = req.params.id as string;
    const notification = await prisma.notification.findFirst({ where: { id, userId } });
    if (!notification) return res.status(404).json({ message: 'Not found' }) as any;
    await prisma.notification.delete({ where: { id } });
    res.json({ message: 'Deleted' });
  } catch (e) {
    res.status(500).json({ message: 'Failed to delete notification' });
  }
};
