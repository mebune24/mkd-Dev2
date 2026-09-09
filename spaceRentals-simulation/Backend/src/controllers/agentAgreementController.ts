import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { agentAgreementService } from '../services/AgentAgreementService';

const handle = (res: Response, error: any) =>
  res.status(error?.status ?? 500).json({ message: error?.message ?? 'Internal server error' });

export const listAgreements = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentAgreementService.listForUser(req.user!.userId, req.user!.role)); }
  catch (error) { return handle(res, error); }
};

export const requestAgreement = async (req: AuthRequest, res: Response) => {
  try { return res.status(201).json(await agentAgreementService.request(req.user!.userId, String(req.body.agentId), String(req.body.serviceTerms ?? ''))); }
  catch (error) { return handle(res, error); }
};

export const decideAgreement = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentAgreementService.decide(req.user!.userId, String(req.params.id), req.body.accept === true)); }
  catch (error) { return handle(res, error); }
};
