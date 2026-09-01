import { Router, Response } from 'express';
import { AuthRequest, authenticate, requireAdmin } from '../middleware/authMiddleware';
import { auditLogService } from '../services/AuditLogService';
import { asyncHandler } from '../utils/asyncHandler';

const router = Router();

// POST /api/audit-logs — record an event (any authenticated user)
router.post('/', authenticate, asyncHandler(async (req: AuthRequest, res: Response) => {
  const { action, resourceId, resourceType, metadata, signatureHash } = req.body;

  if (!action || !resourceId || !resourceType) {
    return res.status(400).json({ message: 'action, resourceId, and resourceType are required' });
  }

  await auditLogService.log({
    userId: req.user!.userId,
    action,
    resourceId,
    resourceType,
    metadata,
    signatureHash,
    ipAddress: req.ip,
    userAgent: req.headers['user-agent'] as string | undefined,
  });

  return res.status(201).json({ message: 'Audit entry recorded' });
}));

// GET /api/audit-logs/resource/:type/:id — trail for a resource (admin only)
router.get('/resource/:type/:id', authenticate, requireAdmin, asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id, type } = req.params as { id: string; type: string };
  const logs = await auditLogService.getByResource(id, type);
  return res.json(logs);
}));

// GET /api/audit-logs/me — own audit trail (signed-in user)
router.get('/me', authenticate, asyncHandler(async (req: AuthRequest, res: Response) => {
  const logs = await auditLogService.getByUser(req.user!.userId);
  return res.json(logs);
}));

export default router;
