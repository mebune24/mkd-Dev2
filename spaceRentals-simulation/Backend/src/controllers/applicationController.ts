import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { applicationService } from '../services/ApplicationService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[ApplicationController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/applications/tenant
export const getTenantApplications = async (req: AuthRequest, res: Response) => {
  try { return res.json(await applicationService.getTenantApplications(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/applications/landlord
export const getLandlordApplications = async (req: AuthRequest, res: Response) => {
  try { return res.json(await applicationService.getLandlordApplications(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// POST /api/applications
export const submitApplication = async (req: AuthRequest, res: Response) => {
  try {
    const { propertyId, coverLetter } = req.body;
    const result = await applicationService.submit(propertyId, req.user!.userId, coverLetter);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// PATCH /api/applications/:id/approve
export const approveApplication = async (req: AuthRequest, res: Response) => {
  try {
    const result = await applicationService.approve(String(req.params.id), req.user!.userId, req.body?.note);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};

// PATCH /api/applications/:id/reject
export const rejectApplication = async (req: AuthRequest, res: Response) => {
  try {
    const result = await applicationService.reject(String(req.params.id), req.user!.userId, req.body?.note);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};

// PATCH /api/applications/:id/withdraw
export const withdrawApplication = async (req: AuthRequest, res: Response) => {
  try {
    const result = await applicationService.withdraw(String(req.params.id), req.user!.userId);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};
