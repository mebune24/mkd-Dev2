import { prisma } from '../lib/prisma';

const walletInclude = { entries: { orderBy: { createdAt: 'desc' as const } } };

export class TenantWalletService {
  async getWallet(tenantId: string) {
    const wallet = await prisma.tenantWallet.upsert({
      where: { tenantId },
      update: {},
      create: { tenantId, referralCode: `SPACE-${tenantId.slice(0, 6).toUpperCase()}` },
      include: walletInclude,
    });
    return this.serialize(wallet);
  }

  async applyToRent(tenantId: string, amount: number) {
    if (!Number.isInteger(amount) || amount <= 0) throw { status: 400, message: 'Amount must be a positive integer.' };
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.tenantWallet.upsert({
        where: { tenantId }, update: {},
        create: { tenantId, referralCode: `SPACE-${tenantId.slice(0, 6).toUpperCase()}` },
      });
      if (wallet.balance < amount) throw { status: 400, message: 'Insufficient wallet balance.' };
      const updated = await tx.tenantWallet.update({ where: { id: wallet.id }, data: { balance: { decrement: amount } } });
      await tx.tenantWalletEntry.create({ data: { walletId: wallet.id, type: 'rent_credit', amount: -amount, description: 'Applied to rent' } });
      return { balance: updated.balance, appliedAmount: amount };
    });
  }

  async requestWithdrawal(tenantId: string, amount: number, method: string, destination: string) {
    if (!Number.isInteger(amount) || amount <= 0) throw { status: 400, message: 'Amount must be a positive integer.' };
    if (!['MTN', 'ORANGE', 'BANK_CARD'].includes(method)) throw { status: 400, message: 'Unsupported withdrawal method.' };
    if (!destination?.trim()) throw { status: 400, message: 'A phone number or bank-card destination is required.' };
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.tenantWallet.upsert({
        where: { tenantId }, update: {},
        create: { tenantId, referralCode: `SPACE-${tenantId.slice(0, 6).toUpperCase()}` },
      });
      if (wallet.balance < amount) throw { status: 400, message: 'Insufficient wallet balance.' };
      const updated = await tx.tenantWallet.update({ where: { id: wallet.id }, data: { balance: { decrement: amount } } });
      const withdrawal = await tx.tenantWithdrawal.create({ data: { walletId: wallet.id, amount, method, destination: destination.trim() } });
      await tx.tenantWalletEntry.create({ data: { walletId: wallet.id, type: 'withdrawal', amount: -amount, description: `Withdrawal via ${method}`, referenceId: withdrawal.id } });
      return { balance: updated.balance, withdrawal };
    });
  }

  private serialize(wallet: any) {
    return {
      id: wallet.id,
      referralCode: wallet.referralCode,
      balance: wallet.balance,
      entries: wallet.entries.map((entry: any) => ({ ...entry, createdAt: entry.createdAt.toISOString() })),
    };
  }
}

export const tenantWalletService = new TenantWalletService();
