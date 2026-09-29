import { applicationRepository } from '../repositories/ApplicationRepository';
import { propertyRepository } from '../repositories/PropertyRepository';
import { leaseRepository } from '../repositories/LeaseRepository';
import { leaseService } from './LeaseService';
import { prisma } from '../lib/prisma';
import { auditLogService } from './AuditLogService';
import { fapshiPaymentService } from './FapshiPaymentService';

// Non-refundable processing fee charged per application (in XAF)
export const APPLICATION_FEE_XAF = 500;

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

  /**
   * Initiates an application by charging the tenant the APPLICATION_FEE first.
   * A pending application record is created immediately.
   * The application status is set to 'submitted' only after payment succeeds via webhook.
   * Returns: { applicationId, paymentLink, gatewayTxId }
   */
  async submit(
    propertyId: string,
    tenantId: string,
    role: string,
    email: string,
    phoneNumber: string,
    paymentMethod: string,
    coverLetter?: string,
    nationalIdUrl?: string,
    proofOfIncomeUrl?: string,
  ) {
    if (role !== 'tenant') throw { status: 403, message: 'Only tenants can submit applications.' };
    const property = await propertyRepository.findById(propertyId);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.status !== 'available') throw { status: 409, message: 'Property is no longer available.' };
    if (!nationalIdUrl || !proofOfIncomeUrl) throw { status: 400, message: 'All required documents must be uploaded.' };
    if (!email) throw { status: 400, message: 'Email is required for payment processing.' };
    if (!phoneNumber) throw { status: 400, message: 'Phone number is required for Mobile Money payment.' };

    const existing = await applicationRepository.countByPropertyAndTenant(propertyId, tenantId);
    if (existing > 0) throw { status: 409, message: 'You have already applied for this property.' };

    // 1. Create application in 'pending_payment' state
    const app = await applicationRepository.create({
      property: { connect: { id: propertyId } },
      tenant: { connect: { id: tenantId } },
      coverLetter,
      nationalIdUrl,
      proofOfIncomeUrl,
      status: 'pending_payment',
    });

    // 2. Charge the tenant the non-refundable application fee
    const payment = await fapshiPaymentService.initiatePayment({
      userId: tenantId,
      amount: APPLICATION_FEE_XAF,
      email,
      phoneNumber,
      message: `Space Rentals — Application fee for ${property.title}`,
      referenceType: 'APPLICATION_FEE',
      referenceId: app.id,
      paymentMethod,
    });

    await auditLogService.log({
      userId: tenantId,
      action: 'application.fee_initiated',
      resourceId: app.id,
      resourceType: 'application',
      metadata: { propertyId, fee: APPLICATION_FEE_XAF, gatewayTxId: payment.gatewayTxId },
    });

    return {
      applicationId: app.id,
      paymentLink: payment.paymentLink,
      gatewayTxId: payment.gatewayTxId,
      fee: APPLICATION_FEE_XAF,
    };
  }

  /**
   * Called by FapshiPaymentService.handleWebhook when an APPLICATION_FEE payment succeeds.
   * Transitions the application from 'pending_payment' → 'submitted'.
   */
  async handleApplicationFeeSuccess(applicationId: string) {
    const app = await applicationRepository.findById(applicationId);
    if (!app) {
      console.warn(`[ApplicationService] Application ${applicationId} not found for fee success.`);
      return;
    }
    if (app.status !== 'pending_payment') {
      console.log(`[ApplicationService] Application ${applicationId} already in state: ${app.status}. Skipping.`);
      return;
    }

    await applicationRepository.update(applicationId, { status: 'submitted' });

    await auditLogService.log({
      userId: app.tenantId,
      action: 'application.submitted',
      resourceId: applicationId,
      resourceType: 'application',
      metadata: { propertyId: app.propertyId, feeCollected: APPLICATION_FEE_XAF },
    });

    console.log(`[ApplicationService] Application ${applicationId} activated after fee payment.`);
  }

  async approve(id: string, landlordId: string, note?: string) {
    const app = await applicationRepository.findById(id);
    if (!app) throw { status: 404, message: 'Application not found.' };
    if (app.property.landlordId !== landlordId) throw { status: 403, message: 'Forbidden.' };
    if (app.status !== 'submitted' && app.status !== 'under_review') {
      throw { status: 400, message: 'Cannot approve an application in its current state.' };
    }
    
    const result = await prisma.$transaction(async (tx) => {
      const reserved = await tx.property.updateMany({
        where: { id: app.propertyId, status: 'available' },
        data: { status: 'reserved' },
      });
      if (reserved.count !== 1) throw { status: 409, message: 'Property is no longer available.' };
      await tx.application.updateMany({
        where: { propertyId: app.propertyId, id: { not: id }, status: { in: ['submitted', 'under_review'] } },
        data: { status: 'rejected', landlordNote: 'Another application was approved.' },
      });
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
    if (!['submitted', 'under_review'].includes(app.status)) {
      throw { status: 400, message: 'Cannot reject an application in its current state.' };
    }
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
