import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { landlordVerificationService } from '../services/LandlordVerificationService';

const handle = (res: Response, err: any) => {
  return res.status(err?.status || 500).json({ message: err?.message || 'Internal server error' });
};

export const submit = async (req: AuthRequest, res: Response) => {
  try {
    return res.status(201).json(await landlordVerificationService.submit(
      req.user!.userId,
      req.body.tier,
      req.body.documents,
    ));
  } catch (err) { return handle(res, err); }
};

export const getMy = async (req: AuthRequest, res: Response) => {
  try { return res.json(await landlordVerificationService.getMy(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const getAll = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await landlordVerificationService.getAll()); }
  catch (err) { return handle(res, err); }
};

export const approve = async (req: AuthRequest, res: Response) => {
  try { return res.json(await landlordVerificationService.approve(String(req.params.id), req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

export const reject = async (req: AuthRequest, res: Response) => {
  try { return res.json(await landlordVerificationService.reject(String(req.params.id), req.user!.userId, req.body.adminNote)); }
  catch (err) { return handle(res, err); }
};
