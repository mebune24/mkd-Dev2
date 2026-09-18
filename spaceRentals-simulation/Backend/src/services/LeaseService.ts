import { leaseRepository } from '../repositories/LeaseRepository';
import { applicationRepository } from '../repositories/ApplicationRepository';
import { prisma } from '../lib/prisma';
import { auditLogService } from './AuditLogService';
import { hasVerifiedLandlordAccess } from '../middleware/authMiddleware';

export class LeaseService {
  private async getPartyLease(id: string, userId: string, role: string) {
    const lease = await leaseRepository.findById(id);
    if (!lease) throw { status: 404, message: 'Lease not found.' };
    if (lease.application.status !== 'approved') {
      throw { status: 409, message: 'Only approved applications can be changed.' };
    }
    if (lease.tenantId !== userId && lease.landlordId !== userId && role !== 'admin') {
      throw { status: 403, message: 'You are not a party on this lease.' };
    }
    return lease;
  }

  async accept(leaseId: string, userId: string, role: string) {
    const lease = await this.getPartyLease(leaseId, userId, role);
    if (lease.status === 'rejected' || lease.status === 'signed') {
      throw { status: 409, message: 'This lease can no longer be accepted.' };
    }
    if (lease.tenantId === userId && lease.status === 'generated') {
      return leaseRepository.update(leaseId, { status: 'tenant_accepted' });
    }
    if (lease.landlordId === userId && lease.status === 'tenant_accepted') {
      return leaseRepository.update(leaseId, { status: 'landlord_accepted' });
    }
    throw { status: 409, message: 'The other party must accept the lease first.' };
  }

  async reject(leaseId: string, userId: string, role: string, reason?: string) {
    const lease = await this.getPartyLease(leaseId, userId, role);
    if (lease.status === 'signed') {
      throw { status: 409, message: 'A fully signed lease cannot be rejected.' };
    }
    return leaseRepository.update(leaseId, { status: 'rejected' });
  }

  /**
   * Get a single lease by ID. Only accessible by tenant, landlord on the lease, or admin.
   */
  async getById(id: string, userId: string, role: string) {
    const lease = await leaseRepository.findById(id);
    if (!lease) throw { status: 404, message: 'Lease not found.' };
    if (lease.application.status !== 'approved') {
      throw { status: 409, message: 'Only approved applications can be signed.' };
    }
    const isParty = lease.tenantId === userId || lease.landlordId === userId;
    if (!isParty && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    return lease;
  }

  /**
   * All leases for the logged-in tenant.
   */
  async getTenantLeases(tenantId: string) {
    return leaseRepository.findByTenant(tenantId);
  }

  /**
   * All leases for the logged-in landlord.
   */
  async getLandlordLeases(landlordId: string) {
    return leaseRepository.findByLandlord(landlordId);
  }

  /**
   * All leases (admin only).
   */
  async getAll() {
    return prisma.lease.findMany({
      include: { property: true, tenant: true, landlord: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Get a lease by its parent application ID.
   */
  async getByApplicationId(applicationId: string, userId: string, role: string) {
    const lease = await leaseRepository.findByApplicationId(applicationId);
    if (!lease) throw { status: 404, message: 'No lease found for this application.' };
    if (lease.application.status !== 'approved') {
      throw { status: 409, message: 'Only approved applications can be signed.' };
    }
    const isParty = lease.tenantId === userId || lease.landlordId === userId;
    if (!isParty && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    return lease;
  }

  /**
   * Sign a lease.
   *
   * State machine:
   *   generated → (tenant signs) → pending_landlord
   *   generated → (landlord signs) → pending_tenant
   *   pending_landlord → (landlord signs) → signed
   *   pending_tenant → (tenant signs) → signed
  *   signed → awaits the initial deposit and first-rent payment
   */
  async sign(leaseId: string, userId: string, role: string, signatureHash?: string, signedIp?: string) {
    const lease = await leaseRepository.findById(leaseId);
    if (!lease) throw { status: 404, message: 'Lease not found.' };
    if (lease.application.status !== 'approved') {
      throw { status: 409, message: 'Only approved applications can be signed.' };
    }

    // Verify the user is a party on this lease
    const isTenant = lease.tenantId === userId;
    const isLandlord = lease.landlordId === userId;

    if (!isTenant && !isLandlord) {
      throw { status: 403, message: 'You are not a party on this lease.' };
    }
    if (isLandlord && !lease.tenantSignedAt) {
      throw { status: 409, message: 'The tenant must sign the lease first.' };
    }
    if (lease.status !== 'landlord_accepted' && lease.status !== 'pending_landlord' && lease.status !== 'pending_tenant') {
      throw { status: 409, message: 'Both parties must accept the lease before signing.' };
    }
    if (isLandlord && !(await hasVerifiedLandlordAccess({ userId, role: role as any }))) {
      throw { status: 403, message: 'Approved landlord verification is required before signing a lease.' };
    }

    // Idempotency: already signed by this party?
    if (isTenant && lease.tenantSignedAt) {
      throw { status: 400, message: 'You have already signed this lease.' };
    }
    if (isLandlord && lease.landlordSignedAt) {
      throw { status: 400, message: 'You have already signed this lease.' };
    }

    const now = new Date();
    const updateData: Record<string, unknown> = {};

    if (isTenant) {
      updateData.tenantSignedAt = now;
      if (signatureHash) updateData.tenantSignatureHash = signatureHash;
      if (signedIp) updateData.tenantSignedIp = signedIp;
    } else {
      updateData.landlordSignedAt = now;
      if (signatureHash) updateData.landlordSignatureHash = signatureHash;
      if (signedIp) updateData.landlordSignedIp = signedIp;
    }

    // The approved tenant signs first; the landlord signs second.
    const tenantSigned = isTenant ? true : !!lease.tenantSignedAt;
    const landlordSigned = isLandlord ? true : !!lease.landlordSignedAt;

    if (tenantSigned && landlordSigned) {
      updateData.status = 'signed';
    } else if (isTenant) {
      updateData.status = 'pending_landlord';
    } else {
      updateData.status = 'pending_tenant';
    }

    const updated = await prisma.$transaction(async (tx) => {
      const updatedLease = await tx.lease.update({
        where: { id: leaseId },
        data: {
          ...updateData,
        },
        include: { property: true, tenant: true, landlord: true },
      });

      return updatedLease;
    });

    // Immutable audit trail — OHADA-aligned e-signature record
    await auditLogService.log({
      userId,
      action: 'lease.signed',
      resourceId: leaseId,
      resourceType: 'lease',
      metadata: { role, isTenant, isLandlord, newStatus: updateData.status },
      signatureHash,
    });

    return updated;
  }

  /**
   * Populate lease tenant & landlord from application when application is approved.
   * Called by ApplicationService.approve().
   */
  async populatePartiesFromApplication(leaseId: string, applicationId: string) {
    const app = await applicationRepository.findById(applicationId);
    if (!app) return;
    return leaseRepository.update(leaseId, {
      tenant: { connect: { id: app.tenantId } },
      landlord: { connect: { id: app.property.landlordId } },
    });
  }
}

export const leaseService = new LeaseService();
