import { applicationRepository } from '../repositories/ApplicationRepository';
import { propertyRepository } from '../repositories/PropertyRepository';
import { leaseRepository } from '../repositories/LeaseRepository';
import { leaseService } from './LeaseService';
import { prisma } from '../lib/prisma';
import { auditLogService } from './AuditLogService';

export class ApplicationService {
  async getTenantApplications(tenantId: string) {
    return applicationRepository.findByTenant(tenantId);
  }

  async getLandlordApplications(landlordId: string) {
    return applicationRepository.findByLandlord(landlordId);
  }

  async getById(id: string, userId: string, role: string) {
    const app = await applicationRepository.findById(id);
    if (!app) throw { status: 404, message: 'Application not found.' };
    const isOwner = app.tenantId === userId || app.property.landlordId === userId;
    if (!isOwner && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    return app;
  }

  async submit(propertyId: string, tenantId: string, coverLetter?: string, nationalIdUrl?: string, proofOfIncomeUrl?: string) {
    const property = await propertyRepository.findById(propertyId);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.status !== 'available') throw { status: 409, message: 'Property is no longer available.' };

    const existing = await applicationRepository.countByPropertyAndTenant(propertyId, tenantId);
    if (existing > 0) throw { status: 409, message: 'You have already applied for this property.' };

    const app = await applicationRepository.create({
      property: { connect: { id: propertyId } },
      tenant: { connect: { id: tenantId } },
      coverLetter,
      nationalIdUrl,
      proofOfIncomeUrl,
      status: 'submitted',
    });

    await auditLogService.log({
      userId: tenantId,
      action: 'application.submitted',
      resourceId: app.id,
      resourceType: 'application',
      metadata: { propertyId },
    });

    return app;
  }

  async approve(id: string, landlordId: string, note?: string) {
    const app = await applicationRepository.findById(id);
    if (!app) throw { status: 404, message: 'Application not found.' };
    if (app.property.landlordId !== landlordId) throw { status: 403, message: 'Forbidden.' };
    if (app.status !== 'submitted' && app.status !== 'under_review') {
      throw { status: 400, message: 'Cannot approve an application in its current state.' };
    }
    
    const result = await prisma.$transaction(async (tx) => {
      const updated = await tx.application.update({
        where: { id },
        data: { status: 'approved', landlordNote: note }
      });
      
      const existingLease = await tx.lease.findUnique({ where: { applicationId: id } });
      let leaseId: string | undefined;
      if (!existingLease) {
        const lease = await tx.lease.create({
          data: {
            application: { connect: { id } },
            property: { connect: { id: app.propertyId } },
            tenant: { connect: { id: app.tenantId } },
            landlord: { connect: { id: app.property.landlordId } },
            status: 'generated',
          }
        });
        leaseId = lease.id;
      } else {
        leaseId = existingLease.id;
      }
      return { updated, leaseId };
    });

    await auditLogService.log({
      userId: landlordId,
      action: 'application.approved',
      resourceId: id,
      resourceType: 'application',
      metadata: { note, leaseId: result.leaseId },
    });

    return result.updated;
  }

  async reject(id: string, landlordId: string, note?: string) {
    const app = await applicationRepository.findById(id);
    if (!app) throw { status: 404, message: 'Application not found.' };
    if (app.property.landlordId !== landlordId) throw { status: 403, message: 'Forbidden.' };
    const updated = await applicationRepository.update(id, { status: 'rejected', landlordNote: note });
    await auditLogService.log({
      userId: landlordId,
      action: 'application.rejected',
      resourceId: id,
      resourceType: 'application',
      metadata: { note },
    });
    return updated;
  }

  async withdraw(id: string, tenantId: string) {
    const app = await applicationRepository.findById(id);
    if (!app) throw { status: 404, message: 'Application not found.' };
    if (app.tenantId !== tenantId) throw { status: 403, message: 'Forbidden.' };
    if (!['submitted', 'under_review'].includes(app.status)) {
      throw { status: 400, message: 'Cannot withdraw an application in its current state.' };
    }
    return applicationRepository.update(id, { status: 'withdrawn' });
  }
}

export const applicationService = new ApplicationService();
