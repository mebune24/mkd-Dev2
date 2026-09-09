import { prisma } from '../lib/prisma';
import { emitUserNotification } from '../socket';

export interface NotificationPayload {
  userId: string;
  type: string;
  title: string;
  body: string;
  metadata?: Record<string, string>;
}

/**
 * Helper to create an in-app notification for a user.
 * This is fire-and-forget — errors are logged but never thrown.
 */
export const sendNotification = async (payload: NotificationPayload): Promise<void> => {
  try {
    const notification = await prisma.notification.create({
      data: {
        userId: payload.userId,
        type: payload.type,
        title: payload.title,
        body: payload.body,
        metadata: payload.metadata ? JSON.stringify(payload.metadata) : undefined,
      },
    });
    emitUserNotification(payload.userId, {
      id: notification.id,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      metadata: payload.metadata,
      createdAt: notification.createdAt.toISOString(),
    });
  } catch (e) {
    console.error('[NotificationService] Failed to send notification:', e);
  }
};
