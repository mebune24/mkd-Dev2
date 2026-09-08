import { Response } from 'express';
import { prisma } from '../lib/prisma';
import { AuthRequest } from '../middleware/authMiddleware';
import { emitPropertyEngagementUpdated } from '../socket';

async function propertyExists(propertyId: string) {
  return prisma.property.findUnique({ where: { id: propertyId }, select: { id: true } });
}

export const togglePropertyLike = async (req: AuthRequest, res: Response) => {
  const propertyId = String(req.params.id);
  const userId = req.user!.userId;
  if (!await propertyExists(propertyId)) return res.status(404).json({ message: 'Property not found' });

  const existing = await prisma.propertyLike.findUnique({ where: { propertyId_userId: { propertyId, userId } } });
  if (existing) await prisma.propertyLike.delete({ where: { id: existing.id } });
  else await prisma.propertyLike.create({ data: { propertyId, userId } });

  const likes = await prisma.propertyLike.count({ where: { propertyId } });
  const payload = { propertyId, likes, likedByMe: !existing };
  emitPropertyEngagementUpdated(payload);
  return res.json(payload);
};

export const togglePropertyReshare = async (req: AuthRequest, res: Response) => {
  const propertyId = String(req.params.id);
  const userId = req.user!.userId;
  if (!await propertyExists(propertyId)) return res.status(404).json({ message: 'Property not found' });

  const existing = await prisma.propertyReshare.findUnique({ where: { propertyId_userId: { propertyId, userId } } });
  if (existing) await prisma.propertyReshare.delete({ where: { id: existing.id } });
  else await prisma.propertyReshare.create({ data: { propertyId, userId } });

  const reshares = await prisma.propertyReshare.count({ where: { propertyId } });
  const payload = { propertyId, reshares, resharedByMe: !existing };
  emitPropertyEngagementUpdated(payload);
  return res.json(payload);
};