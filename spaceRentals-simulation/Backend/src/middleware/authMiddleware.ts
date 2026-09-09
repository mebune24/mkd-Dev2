import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';

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
export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  try {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) return res.status(500).json({ message: 'Server misconfiguration: JWT_SECRET not set.' });
    const decoded = jwt.verify(token, jwtSecret) as {
      userId: string;
      role: UserRole;
    };
    const user = await prisma.user.findUnique({ where: { id: decoded.userId }, select: { role: true, status: true } });
    if (!user || user.status === 'suspended' || user.role !== decoded.role) {
      return res.status(401).json({ message: 'Account is inactive or credentials are stale' });
    }
    req.user = { userId: decoded.userId, role: decoded.role };
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

export const optionalAuthenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return next();
  }

  try {
    const jwtSecret = process.env.JWT_SECRET;
    if (jwtSecret) {
      const decoded = jwt.verify(token, jwtSecret) as { userId: string; role: UserRole };
      req.user = { userId: decoded.userId, role: decoded.role };
    }
  } catch {
    // Ignore invalid tokens for optional auth
  }
  next();
};

// ──────────────────────────────────────────────
// RBAC — role-based access control
// ──────────────────────────────────────────────
export const requireRole = (...roles: (UserRole | UserRole[])[]) =>
  (req: AuthRequest, res: Response, next: NextFunction) => {
    const flatRoles = roles.flat() as UserRole[];
    if (!req.user) return res.status(401).json({ message: 'Authentication required' });
    if (!flatRoles.includes(req.user.role)) {
      return res.status(403).json({
        message: `Access denied. Required role: ${flatRoles.join(' or ')}.`,
      });
    }
    next();
  };

// Convenience shorthands
export const requireAdmin   = requireRole('admin');
export const requireLandlord = requireRole('admin', 'landlord');
export const requireAgent   = requireRole('admin', 'agent');
export const requireTenant  = requireRole('admin', 'tenant');

/**
 * Landlord role alone is deliberately not enough to operate a landlord
 * account.  Keep this check at the API boundary so it cannot be bypassed by
 * navigating directly to a Flutter route or calling the REST API.
 */
export const requireVerifiedLandlord = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) => {
  if (!req.user) return res.status(401).json({ message: 'Authentication required' });
  if (req.user.role === 'admin') return next();
  if (req.user.role !== 'landlord') {
    return res.status(403).json({ message: 'Landlord access required.' });
  }

  const verification = await prisma.landlordVerification.findUnique({
    where: { landlordId: req.user.userId },
    select: { status: true },
  });
  if (verification?.status !== 'approved') {
    return res.status(403).json({
      message: 'Approved landlord verification is required before using landlord operations.',
      code: 'LANDLORD_KYC_REQUIRED',
    });
  }
  return next();
};

export const requireVerifiedAgent = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) => {
  if (!req.user) return res.status(401).json({ message: 'Authentication required' });
  if (req.user.role === 'admin') return next();
  if (req.user.role !== 'agent') {
    return res.status(403).json({ message: 'Agent access required.' });
  }

  const verification = await prisma.agentVerification.findUnique({
    where: { agentId: req.user.userId },
    select: { status: true },
  });
  if (verification?.status !== 'approved') {
    return res.status(403).json({
      message: 'Approved agent verification is required before using agent operations.',
      code: 'AGENT_KYC_REQUIRED',
    });
  }
  return next();
};

/** For mixed-role controllers where a route cannot use the middleware. */
export const hasVerifiedLandlordAccess = async (user: NonNullable<AuthRequest['user']>) => {
  if (user.role === 'admin') return true;
  if (user.role !== 'landlord') return false;
  const verification = await prisma.landlordVerification.findUnique({
    where: { landlordId: user.userId },
    select: { status: true },
  });
  return verification?.status === 'approved';
};

/** Apply to mixed tenant/landlord routes to prevent an unverified landlord
 * from reaching an operation through an endpoint that also serves tenants. */
export const requireLandlordVerificationIfApplicable = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) => {
  if (req.user?.role !== 'landlord') return next();
  return requireVerifiedLandlord(req, res, next);
};

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
