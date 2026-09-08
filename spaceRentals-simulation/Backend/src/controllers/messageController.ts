import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { messageService } from '../services/MessageService';

const handle = (res: Response, err: any) =>
  res.status(err?.status || 500).json({ message: err?.message || 'Internal server error' });

export const getConversations = async (req: AuthRequest, res: Response) => {
  try { return res.json(await messageService.getConversations(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const getRoomMessages = async (req: AuthRequest, res: Response) => {
  try { return res.json(await messageService.getRoom(String(req.params.roomId), req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const sendMessage = async (req: AuthRequest, res: Response) => {
  try {
    const { receiverId, body, propertyId } = req.body;
    return res.status(201).json(
      await messageService.send(req.user!.userId, String(receiverId), String(body ?? ''), propertyId),
    );
  } catch (err) { return handle(res, err); }
};

export const markRoomRead = async (req: AuthRequest, res: Response) => {
  try {
    await messageService.markRoomRead(String(req.params.roomId), req.user!.userId);
    return res.json({ message: 'Messages marked as read.' });
  } catch (err) { return handle(res, err); }
};