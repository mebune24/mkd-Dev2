import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { leaseService } from '../services/LeaseService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[LeaseController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/leases/tenant
export const getTenantLeases = async (req: AuthRequest, res: Response) => {
  try { return res.json(await leaseService.getTenantLeases(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/leases/landlord
export const getLandlordLeases = async (req: AuthRequest, res: Response) => {
  try { return res.json(await leaseService.getLandlordLeases(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/leases (admin)
export const getAllLeases = async (req: AuthRequest, res: Response) => {
  try { return res.json(await leaseService.getAll()); }
  catch (err) { return handle(res, err); }
};

// GET /api/leases/:id
export const getLeaseById = async (req: AuthRequest, res: Response) => {
  try { return res.json(await leaseService.getById(String(req.params.id), req.user!.userId, req.user!.role)); }
  catch (err) { return handle(res, err); }
};

// PATCH /api/leases/:id/sign
export const signLease = async (req: AuthRequest, res: Response) => {
  try { 
    const { signatureHash, signedIp } = req.body;
    return res.json(await leaseService.sign(String(req.params.id), req.user!.userId, req.user!.role, signatureHash, signedIp)); 
  }
  catch (err) { return handle(res, err); }
};
