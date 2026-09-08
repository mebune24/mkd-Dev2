import { prisma } from '../lib/prisma';

const roomFor = (firstUserId: string, secondUserId: string) =>
  [firstUserId, secondUserId].sort().join(':');

export class MessageService {
  async getConversations(userId: string) {
    const messages = await prisma.message.findMany({
      where: { OR: [{ senderId: userId }, { receiverId: userId }] },
      include: {
        sender: { select: { id: true, name: true, role: true, avatarUrl: true } },
        receiver: { select: { id: true, name: true, role: true, avatarUrl: true } },
        property: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 500,
    });

    const conversations = new Map<string, typeof messages[number]>();
    for (const message of messages) {
      if (!conversations.has(message.roomId)) conversations.set(message.roomId, message);
    }

    return [...conversations.values()].map((message) => {
      const other = message.senderId === userId ? message.receiver : message.sender;
      return {
        roomId: message.roomId,
        participant: other,
        property: message.property,
        lastMessage: message.body,
        lastMessageAt: message.createdAt,
        unreadCount: 0,
      };
    });
  }

  async getRoom(roomId: string, userId: string) {
    return prisma.message.findMany({
      where: {
        roomId,
        OR: [{ senderId: userId }, { receiverId: userId }],
      },
      include: {
        sender: { select: { id: true, name: true, role: true, avatarUrl: true } },
        receiver: { select: { id: true, name: true, role: true, avatarUrl: true } },
      },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  async send(senderId: string, receiverId: string, body: string, propertyId?: string) {
    const text = body.trim();
    if (!text) throw { status: 400, message: 'Message body is required.' };
    if (senderId === receiverId) throw { status: 400, message: 'You cannot message yourself.' };

    const receiver = await prisma.user.findUnique({ where: { id: receiverId }, select: { id: true } });
    if (!receiver) throw { status: 404, message: 'Message recipient not found.' };
    if (propertyId) {
      const property = await prisma.property.findUnique({ where: { id: propertyId }, select: { id: true } });
      if (!property) throw { status: 404, message: 'Property not found.' };
    }

    return prisma.message.create({
      data: {
        roomId: roomFor(senderId, receiverId),
        senderId,
        receiverId,
        body: text,
        propertyId,
      },
      include: {
        sender: { select: { id: true, name: true, role: true, avatarUrl: true } },
        receiver: { select: { id: true, name: true, role: true, avatarUrl: true } },
      },
    });
  }

  async markRoomRead(roomId: string, userId: string) {
    await prisma.message.updateMany({
      where: { roomId, receiverId: userId, readAt: null },
      data: { readAt: new Date() },
    });
  }
}

export const messageService = new MessageService();