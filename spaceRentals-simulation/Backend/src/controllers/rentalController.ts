import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { rentalService } from '../services/RentalService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[RentalController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

export const getAllRentals = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await rentalService.getAll()); }
  catch (err) { return handle(res, err); }
};

export const getTenantRentals = async (req: AuthRequest, res: Response) => {
  try { return res.json(await rentalService.getTenantRentals(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const getLandlordRentals = async (req: AuthRequest, res: Response) => {
  try { return res.json(await rentalService.getLandlordRentals(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const getRentalById = async (req: AuthRequest, res: Response) => {
  try { return res.json(await rentalService.getById(String(req.params.id), req.user!.userId, req.user!.role)); }
  catch (err) { return handle(res, err); }
};

export const endRental = async (req: AuthRequest, res: Response) => {
  try { return res.json(await rentalService.endRental(String(req.params.id), req.user!.userId, req.user!.role)); }
  catch (err) { return handle(res, err); }
};
