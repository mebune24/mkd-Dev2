import { prisma } from '../lib/prisma';
import { userRepository } from '../repositories/UserRepository';
import { auditLogService } from './AuditLogService';
import { supabaseService } from './SupabaseService';
import { sendNotification } from './notificationService';

export class LandlordVerificationService {
  async submit(landlordId: string, tier: string, documents: Record<string, string>) {
    const user = await userRepository.findById(landlordId);
    if (!user || user.role !== 'landlord') {
      throw { status: 403, message: 'Only landlords can submit KYC.' };
    }
    if (!documents || Object.keys(documents).length === 0) {
      throw { status: 400, message: 'At least one KYC document is required.' };
    }
    const requiredDocuments = tier === 'premium'
      ? ['land_title', 'site_plan', 'cni']
      : ['id_card', 'land_doc'];
    const missingDocuments = requiredDocuments.filter((key) => !documents[key]);
    if (missingDocuments.length > 0) {
      throw {
        status: 400,
        message: `Missing required KYC documents: ${missingDocuments.join(', ')}.`,
      };
    }

    // Never trust document paths supplied by the client. Every referenced
    // object must be in this landlord's private KYC folder and exist in the
    // KYC bucket before it becomes reviewable by an administrator.
    for (const path of Object.values(documents)) {
      if (typeof path !== 'string' || !new RegExp(`^${landlordId.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}/[^/]+$`).test(path)) {
        throw { status: 400, message: 'Each KYC document must be an upload belonging to your account.' };
      }
      if (!(await supabaseService.fileExists('kyc-documents', path))) {
        throw { status: 400, message: 'One or more KYC documents could not be found. Please upload them again.' };
      }
    }

    const existing = await prisma.landlordVerification.findUnique({ where: { landlordId } });
    if (existing?.status === 'approved') {
      throw { status: 409, message: 'Your KYC has already been approved.' };
    }

    const data = {
      tier: tier === 'premium' ? 'premium' : 'basic',
      status: 'pending',
      documents: JSON.stringify(documents),
      adminNotes: 'Submitted for manual review.',
    };
    return prisma.$transaction(async (tx) => {
      await tx.user.update({ where: { id: landlordId }, data: { status: 'pending_verification' } });
      return existing
        ? tx.landlordVerification.update({ where: { landlordId }, data })
        : tx.landlordVerification.create({
            data: { landlord: { connect: { id: landlordId } }, ...data },
          });
    });
  }

  async getMy(landlordId: string) {
    return prisma.landlordVerification.findUnique({ where: { landlordId } }) ?? { status: 'not_submitted' };
  }

  async getAll() {
    return prisma.landlordVerification.findMany({
      include: { landlord: { select: { id: true, name: true, email: true } } },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async approve(id: string, adminId: string) {
    const verification = await prisma.landlordVerification.findUnique({ where: { id } });
    if (!verification) throw { status: 404, message: 'Landlord KYC application not found.' };
    if (verification.status !== 'pending') throw { status: 409, message: `KYC is already ${verification.status}.` };
    const updated = await prisma.$transaction(async (tx) => {
      const verificationUpdate = await tx.landlordVerification.update({ where: { id }, data: { status: 'approved' } });
      await tx.user.update({ where: { id: verification.landlordId }, data: { status: 'active' } });
      return verificationUpdate;
    });
    await auditLogService.log({
      userId: adminId,
      action: 'kyc.approved',
      resourceId: id,
      resourceType: 'landlord_verification',
      metadata: { landlordId: verification.landlordId },
    });
    await sendNotification({
      userId: verification.landlordId,
      type: 'landlord_kyc_approved',
      title: 'Landlord verification approved',
      body: 'Your account has been activated. You can now use landlord operations.',
      metadata: { verificationId: id, status: 'approved' },
    });
    return updated;
  }

  async reject(id: string, adminId: string, adminNote?: string) {
    const verification = await prisma.landlordVerification.findUnique({ where: { id } });
    if (!verification) throw { status: 404, message: 'Landlord KYC application not found.' };
    if (verification.status !== 'pending') throw { status: 409, message: `KYC is already ${verification.status}.` };
    const updated = await prisma.$transaction(async (tx) => {
      const verificationUpdate = await tx.landlordVerification.update({
        where: { id },
        data: { status: 'rejected', adminNotes: adminNote },
      });
      await tx.user.update({ where: { id: verification.landlordId }, data: { status: 'kyc_rejected' } });
      return verificationUpdate;
    });
    await auditLogService.log({
      userId: adminId,
      action: 'kyc.rejected',
      resourceId: id,
      resourceType: 'landlord_verification',
      metadata: { landlordId: verification.landlordId, adminNote: adminNote ?? '' },
    });
    await sendNotification({
      userId: verification.landlordId,
      type: 'landlord_kyc_rejected',
      title: 'Landlord verification needs attention',
      body: (adminNote?.trim().length ?? 0) > 0
        ? `Your verification was rejected: ${adminNote}`
        : 'Your verification was rejected. Please resubmit your documents.',
      metadata: { verificationId: id, status: 'rejected' },
    });
    return updated;
  }
}

export const landlordVerificationService = new LandlordVerificationService();
