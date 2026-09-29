import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { landlordWalletService } from '../services/LandlordWalletService';

export const getLandlordWallet = async (req: AuthRequest, res: Response) => {
  try { return res.json(await landlordWalletService.getWallet(req.user!.userId)); }
  catch (error: any) {
    console.error('[LandlordWalletController] getWallet failed:', error);
    return res.status(error?.status || 500).json({ message: error?.message || 'Unable to load wallet.' });
  }
};

export const withdrawLandlordWallet = async (req: AuthRequest, res: Response) => {
  try {
    return res.status(201).json(await landlordWalletService.requestWithdrawal(
      req.user!.userId,
      Number(req.body.amount),
      String(req.body.method || ''),
      String(req.body.destination || ''),
    ));
  } catch (error: any) { return res.status(error?.status || 500).json({ message: error?.message || 'Unable to request withdrawal.' }); }
};
