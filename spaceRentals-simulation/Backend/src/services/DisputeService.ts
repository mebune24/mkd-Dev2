import { prisma } from '../lib/prisma';
import { auditLogService } from './AuditLogService';

export class DisputeService {
  async getAllDisputes(role: string, userId: string) {
    if (role === 'admin') {
      return prisma.dispute.findMany({
        include: { openedBy: true, rental: { include: { property: true, tenant: true, landlord: true } } },
        orderBy: { createdAt: 'desc' },
      });
    }
    
    // Tenants and Landlords only see their own disputes
    return prisma.dispute.findMany({
      where: {
        OR: [
          { openedById: userId },
          { rental: { tenantId: userId } },
          { rental: { landlordId: userId } }
        ]
      },
      include: { openedBy: true, rental: { include: { property: true, tenant: true, landlord: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getById(id: string, role: string, userId: string) {
    const dispute = await prisma.dispute.findUnique({
      where: { id },
      include: { openedBy: true, rental: { include: { property: true, tenant: true, landlord: true } } }
    });
    
    if (!dispute) throw { status: 404, message: 'Dispute not found' };

    const isParty = dispute.rental.tenantId === userId || dispute.rental.landlordId === userId || dispute.openedById === userId;
    if (!isParty && role !== 'admin') {
      throw { status: 403, message: 'Forbidden' };
    }

    return dispute;
  }

  async create(rentalId: string, title: string, description: string, userId: string) {
    const rental = await prisma.rental.findUnique({ where: { id: rentalId } });
    if (!rental) throw { status: 404, message: 'Rental not found' };
    if (rental.status !== 'active') throw { status: 409, message: 'Only active rentals can be disputed.' };

    const isParty = rental.tenantId === userId || rental.landlordId === userId;
    if (!isParty) throw { status: 403, message: 'You are not a party to this rental' };

    const dispute = await prisma.dispute.create({
      data: {
        rental: { connect: { id: rentalId } },
        openedBy: { connect: { id: userId } },
        title,
        description,
        status: 'open',
      }
    });

    // Optionally update rental status to disputed
    await prisma.rental.update({
      where: { id: rentalId },
      data: { status: 'disputed' }
    });

    return dispute;
  }

  async resolve(id: string, resolution: string, adminId: string, role: string) {
    if (role !== 'admin') throw { status: 403, message: 'Only admins can resolve disputes' };
    if (!resolution?.trim()) throw { status: 400, message: 'A resolution note is required.' };

    const existing = await prisma.dispute.findUnique({ where: { id } });
    if (!existing) throw { status: 404, message: 'Dispute not found' };
    if (existing.status === 'resolved') throw { status: 409, message: 'Dispute is already resolved.' };

    const dispute = await prisma.dispute.update({
      where: { id },
      data: {
        status: 'resolved',
        resolution,
      }
    });

    // Reset rental status to active if resolved
    await prisma.rental.update({
      where: { id: dispute.rentalId },
      data: { status: 'active' }
    });

    await auditLogService.log({
      userId: adminId,
      action: 'dispute.resolved',
      resourceId: dispute.id,
      resourceType: 'dispute',
      metadata: { previousStatus: existing.status, resolution },
    });

    return dispute;
  }

  async review(id: string, adminId: string, role: string) {
    if (role !== 'admin') throw { status: 403, message: 'Only admins can review disputes' };
    const existing = await prisma.dispute.findUnique({ where: { id } });
    if (!existing) throw { status: 404, message: 'Dispute not found' };
    if (existing.status !== 'open') throw { status: 409, message: `Dispute is already ${existing.status}.` };
    const dispute = await prisma.dispute.update({ where: { id }, data: { status: 'under_review' } });
    await auditLogService.log({
      userId: adminId,
      action: 'dispute.review_started',
      resourceId: dispute.id,
      resourceType: 'dispute',
      metadata: { previousStatus: existing.status },
    });
    return dispute;
  }
}

export const disputeService = new DisputeService();
