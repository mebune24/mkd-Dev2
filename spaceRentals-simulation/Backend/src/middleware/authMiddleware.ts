import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export type UserRole = 'admin' | 'landlord' | 'tenant' | 'agent';

export interface AuthRequest extends Request {
  user?: {
    userId: string;
    role: UserRole;
  };
}

// ──────────────────────────────────────────────
// AUTHENTICATION
// ──────────────────────────────────────────────
export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret') as {
      userId: string;
      role: UserRole;
    };
    req.user = { userId: decoded.userId, role: decoded.role };
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

// ──────────────────────────────────────────────
// RBAC — role-based access control
// ──────────────────────────────────────────────
export const requireRole = (...roles: UserRole[]) =>
  (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ message: 'Authentication required' });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        message: `Access denied. Required role: ${roles.join(' or ')}.`,
      });
    }
    next();
  };

// Convenience shorthands
export const requireAdmin   = requireRole('admin');
export const requireLandlord = requireRole('admin', 'landlord');
export const requireAgent   = requireRole('admin', 'agent');
export const requireTenant  = requireRole('admin', 'tenant');

// ──────────────────────────────────────────────
// OBJECT-LEVEL AUTHORIZATION helpers
// Call these inside controllers before returning / mutating data.
// ──────────────────────────────────────────────

/**
 * Returns true if the caller is an admin or is the owner of the resource.
 */
export function isOwnerOrAdmin(req: AuthRequest, ownerId: string): boolean {
  if (!req.user) return false;
  return req.user.role === 'admin' || req.user.userId === ownerId;
}

/**
 * Throws a 403 response if the caller is not the owner or an admin.
 */
export function assertOwnerOrAdmin(
  req: AuthRequest,
  res: Response,
  ownerId: string,
): boolean {
  if (!isOwnerOrAdmin(req, ownerId)) {
    res.status(403).json({ message: 'You do not have permission to access this resource.' });
    return false;
  }
  return true;
}
