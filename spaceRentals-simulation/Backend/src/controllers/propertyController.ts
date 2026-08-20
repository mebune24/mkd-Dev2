import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

export const getProperties = async (req: Request, res: Response) => {
  try {
    const properties = await prisma.property.findMany({
      include: {
        landlord: {
          select: { name: true, email: true }
        }
      }
    });
    res.json(properties);
  } catch (error) {
    console.error('Get properties error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const getPropertyById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const property = await prisma.property.findUnique({
      where: { id },
      include: {
        landlord: {
          select: { name: true, email: true }
        }
      }
    });
    
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }
    
    res.json(property);
  } catch (error) {
    console.error('Get property by id error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export const createProperty = async (req: AuthRequest, res: Response) => {
  try {
    const landlordId = req.user?.userId;
    if (!landlordId) return res.status(401).json({ message: 'Unauthorized' });

    const { title, description, location, monthlyRent, deposit, amenities, images } = req.body;
    
    const property = await prisma.property.create({
      data: {
        landlordId,
        title,
        description,
        location,
        monthlyRent: parseInt(monthlyRent),
        deposit: parseInt(deposit),
        amenities: JSON.stringify(amenities || []),
        images: JSON.stringify(images || []),
      }
    });
    
    res.status(201).json(property);
  } catch (error) {
    console.error('Create property error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
