import { Response, NextFunction } from 'express';
import { AuthRequest } from './authMiddleware';
import { propertyRepository } from '../repositories/PropertyRepository';
import { applicationRepository } from '../repositories/ApplicationRepository';

export const verifyPropertyOwnership = async (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role === 'admin') return next();
  
  const propertyId = req.params.id || req.body.propertyId;
  if (!propertyId) return res.status(400).json({ message: 'Property ID missing.' });

  const property = await propertyRepository.findById(propertyId);
  if (!property) return res.status(404).json({ message: 'Property not found.' });
  
  if (property.landlordId !== req.user?.userId) {
    return res.status(403).json({ message: 'Forbidden: You do not own this property.' });
  }
  
  next();
};

export const verifyApplicationOwnership = async (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role === 'admin') return next();
  
  const appId = req.params.id;
  if (!appId) return res.status(400).json({ message: 'Application ID missing.' });

  const app = await applicationRepository.findById(String(appId));
  if (!app) return res.status(404).json({ message: 'Application not found.' });

  const isOwner = app.tenantId === req.user?.userId || app.property.landlordId === req.user?.userId;
  if (!isOwner) {
    return res.status(403).json({ message: 'Forbidden: You do not have access to this application.' });
  }
  
  next();
};
