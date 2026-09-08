import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { prisma } from '../lib/prisma';
import { rnlpService } from '../services/RnlpService';

const handle = (res: Response, err: any) =>
  res.status(err?.status || 500).json({ message: err?.message || 'Internal server error' });

export const getMyRnlp = async (req: AuthRequest, res: Response) => {
  try {
    return res.json(await rnlpService.getOrCreateForTenant(req.user!.userId));
  } catch (err) { return handle(res, err); }
};

export const startInstalmentPayment = async (req: AuthRequest, res: Response) => {
  try {
    const instalment = await prisma.rnlpInstalment.findUnique({
      where: { id: String(req.params.instalmentId) },
      include: { contract: true },
    });
    if (!instalment || instalment.contract.tenantId !== req.user!.userId) {
      return res.status(404).json({ message: 'RNLP instalment not found.' });
    }
    if (instalment.status !== 'due') {
      return res.status(409).json({ message: 'RNLP instalment is not payable.' });
    }
    const updated = await prisma.rnlpInstalment.update({
      where: { id: instalment.id },
      data: { status: 'pending' },
    });
    return res.json(updated);
  } catch (err) { return handle(res, err); }
};