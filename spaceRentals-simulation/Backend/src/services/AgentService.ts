import { prisma } from '../lib/prisma';
import { userRepository } from '../repositories/UserRepository';
import { v4 as uuidv4 } from 'uuid';

export class AgentService {
  // ── KYC ──────────────────────────────────────────────────────────────────

  async submitKyc(agentId: string, data: {
    nationalIdUrl?: string;
    selfieUrl?: string;
    businessDocUrl?: string;
    phone?: string;
  }) {
    const user = await userRepository.findById(agentId);
    if (!user) throw { status: 404, message: 'User not found.' };
    if (user.role !== 'agent') throw { status: 403, message: 'Only agents can submit KYC.' };

    const existing = await prisma.agentVerification.findUnique({ where: { agentId } });
    if (existing && existing.status === 'approved') {
      throw { status: 409, message: 'Your KYC has already been approved.' };
    }

    if (existing) {
      return prisma.agentVerification.update({
        where: { agentId },
        data: {
          ...data,
          documents: JSON.stringify(data),
          status: 'pending',
        },
      });
    }

    return prisma.agentVerification.create({
      data: {
        agent: { connect: { id: agentId } },
        ...data,
        documents: JSON.stringify(data),
        status: 'pending',
      },
    });
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

  async approveKyc(kycId: string) {
    const kyc = await prisma.agentVerification.findUnique({ where: { id: kycId } });
    if (!kyc) throw { status: 404, message: 'KYC application not found.' };
    return prisma.agentVerification.update({
      where: { id: kycId },
      data: { status: 'approved' },
    });
  }

  async rejectKyc(kycId: string, adminNote?: string) {
    const kyc = await prisma.agentVerification.findUnique({ where: { id: kycId } });
    if (!kyc) throw { status: 404, message: 'KYC application not found.' };
    return prisma.agentVerification.update({
      where: { id: kycId },
      data: { status: 'rejected', adminNotes: adminNote },
    });
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
    const stats = await this.getWalletStats(agentId);
    if (amount > stats.availableBalance) {
      throw { status: 400, message: `Insufficient balance. Available: ${stats.availableBalance} FCFA.` };
    }
    const idempotencyKey = `withdrawal_${agentId}_${Date.now()}_${uuidv4()}`;
    const tx = await prisma.agentTransaction.create({
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
