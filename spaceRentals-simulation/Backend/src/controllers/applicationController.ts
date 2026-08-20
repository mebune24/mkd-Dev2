import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

export const getApplications = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const role = req.user?.role;
    
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });
    
    let applications;
    
    if (role === 'tenant') {
      applications = await prisma.application.findMany({
        where: { tenantId: userId },
        include: { property: true }
      });
    } else if (role === 'landlord') {
      // Find applications for properties owned by this landlord
      applications = await prisma.application.findMany({
        where: {
          property: {
            landlordId: userId
          }
        },
        include: { 
          property: true,
          tenant: { select: { name: true, email: true } }
        }
      });
    } else if (role === 'admin') {
      applications = await prisma.application.findMany({
        include: {
          property: true,
          tenant: { select: { name: true, email: true } }
        }
      });
    } else {
      return res.status(403).json({ message: 'Forbidden' });
    }
    
    res.json(applications);
  } catch (error) {
    console.error('Get applications error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const createApplication = async (req: AuthRequest, res: Response) => {
  try {
    const tenantId = req.user?.userId;
    if (!tenantId) return res.status(401).json({ message: 'Unauthorized' });
    
    const { propertyId, coverLetter } = req.body;
    
    // Check if property exists
    const property = await prisma.property.findUnique({ where: { id: propertyId } });
    if (!property) return res.status(404).json({ message: 'Property not found' });
    
    const application = await prisma.application.create({
      data: {
        tenantId,
        propertyId,
        coverLetter
      }
    });
    
    res.status(201).json(application);
  } catch (error) {
    console.error('Create application error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
