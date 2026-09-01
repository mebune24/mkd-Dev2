import { prisma } from '../lib/prisma';

export type AuditAction =
  | 'lease.signed'
  | 'lease.generated'
  | 'application.submitted'
  | 'application.approved'
  | 'application.rejected'
  | 'application.withdrawn'
  | 'property.created'
  | 'property.deleted'
  | 'payment.initiated'
  | 'payment.confirmed'
  | 'payment.failed'
  | 'user.registered'
  | 'user.login'
  | 'kyc.submitted'
  | 'kyc.approved'
  | 'kyc.rejected';

export interface AuditLogEntry {
  userId: string;
  action: AuditAction;
  resourceId: string;
  resourceType: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
  signatureHash?: string;
}

export class AuditLogService {
  async log(entry: AuditLogEntry) {
    try {
      await (prisma as any).auditLog.create({
        data: {
          userId: entry.userId,
          action: entry.action,
          resourceId: entry.resourceId,
          resourceType: entry.resourceType,
          metadata: entry.metadata ? JSON.stringify(entry.metadata) : null,
          ipAddress: entry.ipAddress,
          userAgent: entry.userAgent,
          signatureHash: entry.signatureHash,
        },
      });
    } catch {
      // AuditLog model may not exist yet — structured console fallback
      console.log(
        `[AUDIT] ${new Date().toISOString()} | ${entry.action} | user:${entry.userId} | resource:${entry.resourceType}:${entry.resourceId} | ip:${entry.ipAddress ?? 'unknown'}${entry.signatureHash ? ` | sig:${entry.signatureHash.substring(0, 12)}...` : ''}`
      );
    }
  }

  async getByResource(resourceId: string, resourceType: string) {
    try {
      return await (prisma as any).auditLog.findMany({
        where: { resourceId, resourceType },
        orderBy: { createdAt: 'asc' },
      });
    } catch { return []; }
  }

  async getByUser(userId: string) {
    try {
      return await (prisma as any).auditLog.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 50,
      });
    } catch { return []; }
  }
}

export const auditLogService = new AuditLogService();
