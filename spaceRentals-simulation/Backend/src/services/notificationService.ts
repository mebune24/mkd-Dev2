import { prisma } from '../lib/prisma';

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
    await prisma.notification.create({
      data: {
        userId: payload.userId,
        type: payload.type,
        title: payload.title,
        body: payload.body,
        metadata: payload.metadata ? JSON.stringify(payload.metadata) : undefined,
      },
    });
  } catch (e) {
    console.error('[NotificationService] Failed to send notification:', e);
  }
};
