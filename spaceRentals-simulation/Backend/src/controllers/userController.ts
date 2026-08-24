import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { userService } from '../services/UserService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[UserController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/users
export const getAllUsers = async (req: AuthRequest, res: Response) => {
  try { return res.json(await userService.getAll(req.user!.userId, req.user!.role)); }
  catch (err) { return handle(res, err); }
};

// GET /api/users/:id
export const getUserById = async (req: AuthRequest, res: Response) => {
  try { return res.json(await userService.getById(String(req.params.id), req.user!.userId, req.user!.role)); }
  catch (err) { return handle(res, err); }
};

// PATCH /api/users/:id/suspend
export const suspendUser = async (req: AuthRequest, res: Response) => {
  try { return res.json(await userService.suspend(String(req.params.id), req.user!.role)); }
  catch (err) { return handle(res, err); }
};

// PATCH /api/users/:id/activate
export const activateUser = async (req: AuthRequest, res: Response) => {
  try { return res.json(await userService.activate(String(req.params.id), req.user!.role)); }
  catch (err) { return handle(res, err); }
};
