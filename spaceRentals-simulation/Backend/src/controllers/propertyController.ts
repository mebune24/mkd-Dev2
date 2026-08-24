import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { propertyService } from '../services/PropertyService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[PropertyController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/properties
export const getProperties = async (req: AuthRequest, res: Response) => {
  try { return res.json(await propertyService.getAll()); }
  catch (err) { return handle(res, err); }
};

// GET /api/properties/nearby?lat=xx&lng=xx&radius=xx
export const getNearbyProperties = async (req: AuthRequest, res: Response) => {
  try {
    const lat = Number(req.query.lat);
    const lng = Number(req.query.lng);
    const radius = Number(req.query.radius) || 10;
    
    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ message: 'Valid lat and lng query parameters are required.' });
    }
    
    return res.json(await propertyService.searchNearby(lat, lng, radius));
  } catch (err) { return handle(res, err); }
};

// GET /api/properties/my/listings
export const getMyProperties = async (req: AuthRequest, res: Response) => {
  try { return res.json(await propertyService.getMyProperties(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/properties/:id
export const getPropertyById = async (req: AuthRequest, res: Response) => {
  try { return res.json(await propertyService.getById(String(req.params.id))); }
  catch (err) { return handle(res, err); }
};

// POST /api/properties
export const createProperty = async (req: AuthRequest, res: Response) => {
  try {
    const result = await propertyService.create(req.user!.userId, req.body);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// PATCH /api/properties/:id
export const updateProperty = async (req: AuthRequest, res: Response) => {
  try {
    const result = await propertyService.update(String(req.params.id), req.user!.userId, req.user!.role, req.body);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};

// DELETE /api/properties/:id
export const deleteProperty = async (req: AuthRequest, res: Response) => {
  try {
    const result = await propertyService.delete(String(req.params.id), req.user!.userId, req.user!.role);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};
