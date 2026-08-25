import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { disputeService } from '../services/DisputeService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[DisputeController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/disputes
export const getAllDisputes = async (req: AuthRequest, res: Response) => {
  try { return res.json(await disputeService.getAllDisputes(req.user!.role, req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/disputes/:id
export const getDisputeById = async (req: AuthRequest, res: Response) => {
  try { return res.json(await disputeService.getById(String(req.params.id), req.user!.role, req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// POST /api/disputes
export const createDispute = async (req: AuthRequest, res: Response) => {
  try {
    const { rentalId, title, description } = req.body;
    return res.status(201).json(await disputeService.create(rentalId, title, description, req.user!.userId));
  } catch (err) { return handle(res, err); }
};

// PATCH /api/disputes/:id/resolve
export const resolveDispute = async (req: AuthRequest, res: Response) => {
  try {
    const { resolution } = req.body;
    return res.json(await disputeService.resolve(String(req.params.id), resolution, req.user!.userId, req.user!.role));
  } catch (err) { return handle(res, err); }
};
