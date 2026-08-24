import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { subscriptionService } from '../services/SubscriptionService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[SubscriptionController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/subscriptions/plans
export const getPlans = async (_req: AuthRequest, res: Response) => {
  try { return res.json(subscriptionService.getPlans()); }
  catch (err) { return handle(res, err); }
};

// GET /api/subscriptions/status
export const getStatus = async (req: AuthRequest, res: Response) => {
  try { return res.json(await subscriptionService.getStatus(req.user!.userId)); }
  catch (err) { return handle(res, err); }
};

// POST /api/subscriptions/initiate
export const initiateSubscription = async (req: AuthRequest, res: Response) => {
  try {
    const result = await subscriptionService.initiate(req.user!.userId, req.body);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};
