import { Request, Response } from 'express';
import { authService } from '../services/AuthService';
import { AuthRequest } from '../middleware/authMiddleware';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  const message = err?.message || 'Internal server error';
  console.error('[AuthController]', err);
  return res.status(status).json({ message });
};

// POST /api/auth/register
export const register = async (req: Request, res: Response) => {
  try {
    const result = await authService.register(req.body.name, req.body.email, req.body.password, req.body.role);
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// POST /api/auth/login
export const login = async (req: Request, res: Response) => {
  try {
    const result = await authService.login(req.body.email, req.body.password);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};

// GET /api/auth/me
export const getMe = async (req: AuthRequest, res: Response) => {
  try {
    const result = await authService.getMe(req.user!.userId);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};
