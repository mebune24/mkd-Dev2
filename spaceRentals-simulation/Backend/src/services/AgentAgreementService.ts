import { prisma } from '../lib/prisma';
import { auditLogService } from './AuditLogService';

export class AgentAgreementService {
  async listForUser(userId: string, role: string) {
    const where = role === 'landlord' ? { landlordId: userId } : { agentId: userId };
    return prisma.agentServiceAgreement.findMany({
      where,
      include: {
        landlord: { select: { id: true, name: true } },
        agent: { select: { id: true, name: true, email: true } },
      },
      orderBy: { requestedAt: 'desc' },
    });
  }

  async request(landlordId: string, agentId: string, serviceTerms: string) {
    if (!serviceTerms?.trim()) throw { status: 400, message: 'Service terms are required.' };
    const agent = await prisma.user.findUnique({ where: { id: agentId }, select: { id: true, role: true } });
    if (!agent || agent.role !== 'agent') throw { status: 404, message: 'Agent not found.' };
    const verification = await prisma.agentVerification.findUnique({ where: { agentId }, select: { status: true } });
    if (verification?.status !== 'approved') throw { status: 403, message: 'Only verified agents can receive service requests.' };

    const agreement = await prisma.agentServiceAgreement.upsert({
      where: { landlordId_agentId: { landlordId, agentId } },
      create: { landlordId, agentId, serviceTerms: serviceTerms.trim(), status: 'pending' },
      update: { serviceTerms: serviceTerms.trim(), status: 'pending', acceptedAt: null },
      include: { landlord: { select: { id: true, name: true } }, agent: { select: { id: true, name: true, email: true } } },
    });
    await auditLogService.log({
      userId: landlordId,
      action: 'agent_agreement.requested',
      resourceId: agreement.id,
      resourceType: 'agent_service_agreement',
      metadata: { agentId },
    });
    return agreement;
  }

  async decide(agentId: string, agreementId: string, accept: boolean) {
    const agreement = await prisma.agentServiceAgreement.findUnique({ where: { id: agreementId } });
    if (!agreement || agreement.agentId !== agentId) throw { status: 404, message: 'Agreement not found.' };
    if (agreement.status !== 'pending') throw { status: 409, message: `Agreement is already ${agreement.status}.` };
    const updated = await prisma.agentServiceAgreement.update({
      where: { id: agreementId },
      data: { status: accept ? 'active' : 'terminated', acceptedAt: accept ? new Date() : null },
    });
    await auditLogService.log({
      userId: agentId,
      action: 'agent_agreement.decided',
      resourceId: agreementId,
      resourceType: 'agent_service_agreement',
      metadata: { accepted: accept },
    });
    return updated;
  }
}

export const agentAgreementService = new AgentAgreementService();
