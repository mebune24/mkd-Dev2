import { prisma } from '../lib/prisma';
import { userRepository } from '../repositories/UserRepository';
import { v4 as uuidv4 } from 'uuid';
import { auditLogService } from './AuditLogService';
import { supabaseService } from './SupabaseService';

export class AgentService {
  // ── KYC ──────────────────────────────────────────────────────────────────

  async submitKyc(agentId: string, data: {
    nationalIdUrl?: string;
    selfieUrl?: string;
    businessDocUrl?: string;
    taxCardUrl?: string;
    phone?: string;
  }) {
    const user = await userRepository.findById(agentId);
    if (!user) throw { status: 404, message: 'User not found.' };
    if (user.role !== 'agent') throw { status: 403, message: 'Only agents can submit KYC.' };

    const documentPaths = Object.entries(data).filter(
      ([key, value]) => key.endsWith('Url') && typeof value === 'string' && value.length > 0,
    ) as Array<[string, string]>;
    if (!data.nationalIdUrl) {
      throw { status: 400, message: 'A national ID document is required.' };
    }
    if (documentPaths.some(([, path]) => !path.startsWith(`${agentId}/`) || path.slice(`${agentId}/`.length).includes('/'))) {
      throw { status: 400, message: 'Invalid KYC document path.' };
    }
    for (const [, path] of documentPaths) {
      if (!(await supabaseService.fileExists('kyc-documents', path))) {
        throw { status: 400, message: 'One or more KYC documents could not be found. Please upload them again.' };
      }
    }

    const existing = await prisma.agentVerification.findUnique({ where: { agentId } });
    if (existing && existing.status === 'approved') {
      throw { status: 409, message: 'Your KYC has already been approved.' };
    }

    if (existing) {
      const updated = await prisma.agentVerification.update({
        where: { agentId },
        data: {
          ...data,
          documents: JSON.stringify(data),
          status: 'pending',
          adminNotes: 'Submitted for manual review.',
        },
      });
      await userRepository.update(agentId, { status: 'pending_verification' });
      return updated;
    }

    const created = await prisma.agentVerification.create({
      data: {
        agent: { connect: { id: agentId } },
        ...data,
        documents: JSON.stringify(data),
        status: 'pending',
        adminNotes: 'Submitted for manual review.',
      },
    });
    await userRepository.update(agentId, { status: 'pending_verification' });
    return created;
  }

  async getMyKyc(agentId: string) {
    const kyc = await prisma.agentVerification.findUnique({ where: { agentId } });
    if (!kyc) return { status: 'not_submitted' };
    return kyc;
  }

  async getAllKyc() {
    return prisma.agentVerification.findMany({
      include: { agent: { select: { id: true, name: true, email: true } } },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async getPendingKyc() {
    return prisma.agentVerification.findMany({
      where: { status: 'pending' },
      include: { agent: { select: { id: true, name: true, email: true } } },
      orderBy: { submittedAt: 'asc' },
    });
  }

  async approveKyc(kycId: string, adminId: string) {
    const kyc = await prisma.agentVerification.findUnique({ where: { id: kycId } });
    if (!kyc) throw { status: 404, message: 'KYC application not found.' };
    if (kyc.status !== 'pending') throw { status: 409, message: `KYC is already ${kyc.status}.` };
    const updated = await prisma.agentVerification.update({
      where: { id: kycId },
      data: { status: 'approved' },
    });
    await userRepository.update(kyc.agentId, { status: 'active' });
    await auditLogService.log({
      userId: adminId,
      action: 'kyc.approved',
      resourceId: kyc.id,
      resourceType: 'agent_verification',
      metadata: { agentId: kyc.agentId },
    });
    return updated;
  }

  async rejectKyc(kycId: string, adminId: string, adminNote?: string) {
    const kyc = await prisma.agentVerification.findUnique({ where: { id: kycId } });
    if (!kyc) throw { status: 404, message: 'KYC application not found.' };
    if (kyc.status !== 'pending') throw { status: 409, message: `KYC is already ${kyc.status}.` };
    const updated = await prisma.agentVerification.update({
      where: { id: kycId },
      data: { status: 'rejected', adminNotes: adminNote },
    });
    await userRepository.update(kyc.agentId, { status: 'kyc_rejected' });
    await auditLogService.log({
      userId: adminId,
      action: 'kyc.rejected',
      resourceId: kyc.id,
      resourceType: 'agent_verification',
      metadata: { agentId: kyc.agentId, adminNote: adminNote ?? '' },
    });
    return updated;
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  async getProfile(agentId: string) {
    const user = await userRepository.findById(agentId);
    if (!user) throw { status: 404, message: 'Agent not found.' };
    const kyc = await prisma.agentVerification.findUnique({ where: { agentId } });
    const stats = await this.getWalletStats(agentId);
    return {
      id: user.id,
      name: user.name,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isKycVerified: kyc?.status === 'approved',
      kycStatus: kyc?.status ?? 'not_submitted',
      walletStatus: stats.walletStatus,
    };
  }

  // ── Wallet ────────────────────────────────────────────────────────────────

  async getWallet(agentId: string) {
    const stats = await this.getWalletStats(agentId);
    const withdrawals = await prisma.agentTransaction.findMany({
      where: { agentId, type: 'withdrawal' },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });
    return { ...stats, recentWithdrawals: withdrawals };
  }

  async getWalletStats(agentId: string) {
    const allTx = await prisma.agentTransaction.findMany({ where: { agentId } });
    const pending = allTx.filter(t => t.status === 'pending' && t.amount > 0).reduce((s, t) => s + t.amount, 0);
    const eligible = allTx.filter(t => t.status === 'eligible').reduce((s, t) => s + t.amount, 0);
    const available = allTx.filter(t => t.status === 'available').reduce((s, t) => s + t.amount, 0);
    const withdrawn = allTx.filter(t => t.status === 'paid' && t.amount < 0).reduce((s, t) => s + Math.abs(t.amount), 0);
    return {
      agentId,
      pendingBalance: pending,
      eligibleBalance: eligible,
      availableBalance: available,
      withdrawnBalance: withdrawn,
      walletStatus: 'active',
    };
  }

  async requestWithdrawal(agentId: string, params: { amount: number; phoneNumber: string; paymentMethod: string }) {
    const { amount, phoneNumber, paymentMethod } = params;
    if (!Number.isInteger(amount) || amount <= 0) {
      throw { status: 400, message: 'amount must be a positive integer.' };
    }
    if (!phoneNumber || !['MTN_MOMO', 'ORANGE_MONEY'].includes(paymentMethod)) {
      throw { status: 400, message: 'A valid phone number and payment method are required.' };
    }
    const user = await userRepository.findById(agentId);
    if (!user || user.role !== 'agent') throw { status: 403, message: 'Only agents can withdraw commissions.' };
    const kyc = await prisma.agentVerification.findUnique({ where: { agentId } });
    if (kyc?.status !== 'approved') throw { status: 403, message: 'Approved KYC is required before withdrawing.' };
    const stats = await this.getWalletStats(agentId);
    if (amount > stats.availableBalance) {
      throw { status: 400, message: `Insufficient balance. Available: ${stats.availableBalance} FCFA.` };
    }
    const idempotencyKey = `withdrawal_${agentId}_${Date.now()}_${uuidv4()}`;
    const tx = await prisma.$transaction(async (db) => {
      const withdrawal = await db.agentTransaction.create({
        data: {
          agentId,
          type: 'withdrawal',
          amount: -amount,
          status: 'processing',
          sourceEvent: 'withdrawal_request',
          referenceType: 'WALLET',
          referenceId: agentId,
          idempotencyKey,
        },
      });
      const available = await db.agentTransaction.findMany({
        where: { agentId, type: 'commission', status: 'available', amount: { gt: 0 } },
        orderBy: { createdAt: 'asc' },
      });
      let remaining = amount;
      for (const commission of available) {
        if (remaining <= 0) break;
        const reserved = Math.min(commission.amount, remaining);
        if (reserved === commission.amount) {
          await db.agentTransaction.update({
            where: { id: commission.id },
            data: { status: 'processing', referenceId: withdrawal.id },
          });
        } else {
          await db.agentTransaction.update({
            where: { id: commission.id },
            data: { amount: commission.amount - reserved },
          });
          await db.agentTransaction.create({
            data: {
              agentId,
              type: 'commission',
              amount: reserved,
              status: 'processing',
              sourceEvent: commission.sourceEvent,
              referenceType: commission.referenceType,
              referenceId: withdrawal.id,
              idempotencyKey: `commission-reservation-${withdrawal.id}-${commission.id}`,
            },
          });
        }
        remaining -= reserved;
      }
      if (remaining > 0) throw { status: 400, message: 'Insufficient balance.' };
      return withdrawal;
    });
    return { message: 'Withdrawal initiated.', transaction: tx };
  }

  async getWithdrawals(agentId: string) {
    return prisma.agentTransaction.findMany({
      where: { agentId, type: 'withdrawal' },
      orderBy: { createdAt: 'desc' },
    });
  }

  // ── Commissions ──────────────────────────────────────────────────────────

  async getMyCommissions(agentId: string) {
    return prisma.agentTransaction.findMany({
      where: { agentId, type: 'commission' },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getAllCommissions() {
    return prisma.agentTransaction.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  // ── Marketplace (public list of agents for landlords) ──────────────────

  async listAgents() {
    const agents = await prisma.user.findMany({
      where: { role: 'agent' },
      select: { id: true, name: true, email: true, phone: true, createdAt: true },
    });
    const verifications = await prisma.agentVerification.findMany({
      where: { status: 'approved' },
    });
    const verifiedSet = new Set(verifications.map(v => v.agentId));
    return agents.map(a => ({ ...a, isKycVerified: verifiedSet.has(a.id) }));
  }
}

export const agentService = new AgentService();
