import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { emitPropertyEngagementUpdated } from '../socket';

const prisma = new PrismaClient();

// Add a comment to a property
export const addComment = async (req: Request, res: Response) => {
  try {
    const id = String(req.params.id); // propertyId
    const { content } = req.body;
    
    // @ts-ignore - Assuming auth middleware attaches user to req
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (!content || typeof content !== 'string' || content.trim().length === 0) {
      return res.status(400).json({ error: 'Comment content is required' });
    }

    const comment = await prisma.comment.create({
      data: {
        content: content.trim(),
        propertyId: id,
        userId: userId,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
            role: true,
          }
        }
      }
    });

    res.status(201).json(comment);
    const comments = await prisma.comment.count({ where: { propertyId: id } });
    emitPropertyEngagementUpdated({ propertyId: id, comments });
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get comments for a property
export const getComments = async (req: Request, res: Response) => {
  try {
    const id = String(req.params.id); // propertyId
    
    const comments = await prisma.comment.findMany({
      where: {
        propertyId: id,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
            role: true,
          }
        }
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
