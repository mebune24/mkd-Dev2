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

// PATCH /api/auth/change-password
export const changePassword = async (req: AuthRequest, res: Response) => {
  try {
    const result = await authService.changePassword(req.user!.userId, req.body.currentPassword, req.body.newPassword);
    return res.json(result);
  } catch (err) { return handle(res, err); }
};

import crypto from 'crypto';
import { prisma } from '../lib/prisma';

// POST /api/auth/password-reset — Request a password reset email
export const requestPasswordReset = async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email is required.' });
    
    const user = await prisma.user.findUnique({ where: { email } });
    // Always return 200 to prevent email enumeration attacks
    if (!user) return res.json({ message: 'If that email exists, a reset link has been sent.' });
    
    // Generate a secure token valid for 1 hour
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
    
    // Store the reset token (upsert so previous tokens are replaced)
    await prisma.passwordResetToken.upsert({
      where: { userId: user.id },
      update: { token, expiresAt },
      create: { userId: user.id, token, expiresAt },
    });
    
    // TODO: Send email when email service is configured
    // For now, log the token for development use
    console.log(`[PasswordReset] Token for ${email}: ${token}`);
    
    return res.json({ 
      message: 'If that email exists, a reset link has been sent.',
      // Remove this in production — only for dev
      ...(process.env.NODE_ENV !== 'production' && { devToken: token })
    });
  } catch (err: any) {
    return res.status(500).json({ message: 'Failed to process request.' });
  }
};

// POST /api/auth/password-reset/confirm — Confirm and apply the new password
export const confirmPasswordReset = async (req: Request, res: Response) => {
  try {
    const { token, newPassword } = req.body;
    if (!token || !newPassword) {
      return res.status(400).json({ message: 'token and newPassword are required.' });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters.' });
    }
    
    const resetRecord = await prisma.passwordResetToken.findUnique({ where: { token } });
    if (!resetRecord || resetRecord.expiresAt < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired reset token.' });
    }
    
    const bcrypt = await import('bcrypt');
    const passwordHash = await bcrypt.hash(newPassword, 10);
    
    await prisma.$transaction([
      prisma.user.update({ where: { id: resetRecord.userId }, data: { passwordHash } }),
      prisma.passwordResetToken.delete({ where: { token } }),
    ]);
    
    return res.json({ message: 'Password has been reset successfully. Please log in.' });
  } catch (err: any) {
    return res.status(500).json({ message: 'Failed to reset password.' });
  }
};
