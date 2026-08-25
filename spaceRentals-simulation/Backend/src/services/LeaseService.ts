import { leaseRepository } from '../repositories/LeaseRepository';
import { applicationRepository } from '../repositories/ApplicationRepository';
import { prisma } from '../lib/prisma';

export class LeaseService {
  /**
   * Get a single lease by ID. Only accessible by tenant, landlord on the lease, or admin.
   */
  async getById(id: string, userId: string, role: string) {
    const lease = await leaseRepository.findById(id);
    if (!lease) throw { status: 404, message: 'Lease not found.' };
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
   * Sign a lease.
   *
   * State machine:
   *   generated → (tenant signs) → pending_landlord
   *   generated → (landlord signs) → pending_tenant
   *   pending_landlord → (landlord signs) → signed
   *   pending_tenant → (tenant signs) → signed
   *   signed → auto-creates Rental + sets property status to "rented"
   */
  async sign(leaseId: string, userId: string, role: string, signatureHash?: string, signedIp?: string) {
    const lease = await leaseRepository.findById(leaseId);
    if (!lease) throw { status: 404, message: 'Lease not found.' };

    // Verify the user is a party on this lease
    const isTenant = lease.tenantId === userId;
    const isLandlord = lease.landlordId === userId;

    if (!isTenant && !isLandlord) {
      throw { status: 403, message: 'You are not a party on this lease.' };
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

    // Determine new status
    const tenantSigned = isTenant ? true : !!lease.tenantSignedAt;
    const landlordSigned = isLandlord ? true : !!lease.landlordSignedAt;

    if (tenantSigned && landlordSigned) {
      updateData.status = 'signed';
    } else if (isTenant) {
      updateData.status = 'pending_landlord';
    } else {
      updateData.status = 'pending_tenant';
    }

    const updated = await leaseRepository.update(leaseId, updateData);

    // If fully signed → create Rental and mark property rented
    if (tenantSigned && landlordSigned) {
      const existingRental = await prisma.rental.findUnique({ where: { leaseId } });
      if (!existingRental) {
        await prisma.rental.create({
          data: {
            lease: { connect: { id: leaseId } },
            property: { connect: { id: lease.propertyId } },
            tenant: { connect: { id: lease.tenantId! } },
            landlord: { connect: { id: lease.landlordId! } },
            monthlyRent: lease.property.monthlyRent,
            status: 'active',
            activatedAt: now,
          },
        });
        await prisma.lease.update({ where: { id: leaseId }, data: { status: 'active' } });
        await prisma.property.update({ where: { id: lease.propertyId }, data: { status: 'rented' } });
      }
    }

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
