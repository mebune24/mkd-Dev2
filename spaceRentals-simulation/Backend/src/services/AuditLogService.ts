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
  | 'user.suspended'
  | 'user.activated'
  | 'dispute.review_started'
  | 'dispute.resolved'
  | 'admin.created'
  | 'users.bulk_suspended'
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
    } catch (error) {
      console.error('[AuditLogService] audit persistence failed:', error);
      throw { status: 503, message: 'Audit service unavailable; operation was not completed.' };
    }
  }

  async getByResource(resourceId: string, resourceType: string) {
    try {
      return await (prisma as any).auditLog.findMany({
        where: { resourceId, resourceType },
        orderBy: { createdAt: 'asc' },
      });
    }
    catch (error) {
      console.error('[AuditLogService] resource query failed:', error);
      throw error;
    }
  }

  async getByUser(userId: string) {
    try {
      return await (prisma as any).auditLog.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 50,
      });
    }
    catch (error) {
      console.error('[AuditLogService] user query failed:', error);
      throw error;
    }
  }

  async getAll(limit = 100) {
    try {
      return await (prisma as any).auditLog.findMany({
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, name: true, role: true } } },
      });
    }
    catch (error) {
      console.error('[AuditLogService] admin query failed:', error);
      throw error;
    }
  }
}

export const auditLogService = new AuditLogService();
