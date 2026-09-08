import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { tenantWalletService } from '../services/TenantWalletService';

export const getTenantWallet = async (req: AuthRequest, res: Response) => {
  try { return res.json(await tenantWalletService.getWallet(req.user!.userId)); }
  catch (error: any) { return res.status(error?.status || 500).json({ message: error?.message || 'Unable to load wallet.' }); }
};

export const applyWalletToRent = async (req: AuthRequest, res: Response) => {
  try { return res.json(await tenantWalletService.applyToRent(req.user!.userId, Number(req.body.amount))); }
  catch (error: any) { return res.status(error?.status || 500).json({ message: error?.message || 'Unable to apply wallet balance.' }); }
};

export const withdrawTenantWallet = async (req: AuthRequest, res: Response) => {
  try {
    return res.status(201).json(await tenantWalletService.requestWithdrawal(
      req.user!.userId,
      Number(req.body.amount),
      String(req.body.method || ''),
      String(req.body.destination || ''),
    ));
  } catch (error: any) { return res.status(error?.status || 500).json({ message: error?.message || 'Unable to request withdrawal.' }); }
};
