import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

export const getUsers = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }
    
    const users = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        status: true,
        createdAt: true,
      }
    });
    
    res.json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const submitKyc = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });
    
    const { tier, documents } = req.body;
    
    const kyc = await prisma.kYCSubmission.upsert({
      where: { userId },
      update: {
        tier,
        documents: JSON.stringify(documents),
        status: 'pending',
        submittedAt: new Date()
      },
      create: {
        userId,
        tier,
        documents: JSON.stringify(documents),
      }
    });
    
    res.json(kyc);
  } catch (error) {
    console.error('Submit KYC error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const getKycSubmissions = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }
    
    const submissions = await prisma.kYCSubmission.findMany({
      include: {
        user: { select: { name: true, email: true, role: true } }
      }
    });
    
    res.json(submissions);
  } catch (error) {
    console.error('Get KYC submissions error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
