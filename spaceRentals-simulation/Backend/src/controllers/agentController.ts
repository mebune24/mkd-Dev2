import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { agentService } from '../services/AgentService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[AgentController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/agents  — public marketplace list
export const listAgents = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.listAgents()); }
  catch (err) { return handle(res, err); }
};

// GET /api/agents/profile
export const getAgentProfile = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getProfile(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// ── KYC ─────────────────────────────────────────────────────────────────────

// GET /api/agents/kyc/me
export const getMyKyc = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getMyKyc(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// POST /api/agents/kyc
export const submitKyc = async (req: AuthRequest, res: Response) => {
  try {
    const result = await agentService.submitKyc(req.user!.userId, req.body);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// GET /api/agents/kyc  (admin)
export const getAllKyc = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getAllKyc()); }
  catch (err) { return handle(res, err); }
};

// GET /api/agents/kyc/pending  (admin)
export const getPendingKyc = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getPendingKyc()); }
  catch (err) { return handle(res, err); }
};

// PATCH /api/agents/kyc/:id/approve  (admin)
export const approveKyc = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.approveKyc(String(req.params.id))); }
  catch (err) { return handle(res, err); }
};

// PATCH /api/agents/kyc/:id/reject  (admin)
export const rejectKyc = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.rejectKyc(String(req.params.id), req.body.adminNote)); }
  catch (err) { return handle(res, err); }
};

// ── Wallet ───────────────────────────────────────────────────────────────────

// GET /api/agents/wallet
export const getWallet = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getWallet(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// POST /api/agents/wallet/withdraw
export const requestWithdrawal = async (req: AuthRequest, res: Response) => {
  try {
    const result = await agentService.requestWithdrawal(req.user!.userId, req.body);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// GET /api/agents/wallet/withdrawals
export const getWithdrawals = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getWithdrawals(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// ── Commissions ──────────────────────────────────────────────────────────────

// GET /api/agents/commissions
export const getMyCommissions = async (req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getMyCommissions(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// GET /api/agents/commissions/all  (admin)
export const getAllCommissions = async (_req: AuthRequest, res: Response) => {
  try { return res.json(await agentService.getAllCommissions()); }
  catch (err) { return handle(res, err); }
};
