import { prisma } from '../lib/prisma';

const walletInclude = { entries: { orderBy: { createdAt: 'desc' as const } } };

export class LandlordWalletService {
  async getWallet(landlordId: string) {
    const wallet = await prisma.landlordWallet.upsert({
      where: { landlordId },
      update: {},
      create: { landlordId },
      include: walletInclude,
    });
    return this.serialize(wallet);
  }

  async requestWithdrawal(landlordId: string, amount: number, method: string, destination: string) {
    if (!Number.isInteger(amount) || amount <= 0) throw { status: 400, message: 'Amount must be a positive integer.' };
    if (!['MTN', 'ORANGE', 'BANK'].includes(method)) throw { status: 400, message: 'Unsupported withdrawal method.' };
    if (!destination?.trim()) throw { status: 400, message: 'A valid destination (phone or bank account) is required.' };
    
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.landlordWallet.upsert({
        where: { landlordId }, update: {},
        create: { landlordId },
      });
      
      if (wallet.balance < amount) throw { status: 400, message: 'Insufficient wallet balance.' };
      
      const updated = await tx.landlordWallet.update({ 
        where: { id: wallet.id }, 
        data: { balance: { decrement: amount } } 
      });
      
      const withdrawal = await tx.landlordWithdrawal.create({ 
        data: { walletId: wallet.id, amount, method, destination: destination.trim() } 
      });
      
      await tx.landlordWalletEntry.create({ 
        data: { 
          walletId: wallet.id, 
          type: 'withdrawal', 
          amount: -amount, 
          description: `Withdrawal via ${method}`, 
          referenceId: withdrawal.id 
        } 
      });
      
      return { balance: updated.balance, withdrawal };
    });
  }

  // Internal method called by payment webhooks when rent clears
  async creditRentPayment(landlordId: string, rentAmount: number, leaseId: string) {
    // 5% Platform Success Fee
    const successFee = Math.floor(rentAmount * 0.05);
    const netAmount = rentAmount - successFee;

    return prisma.$transaction(async (tx) => {
      const wallet = await tx.landlordWallet.upsert({
        where: { landlordId }, update: {},
        create: { landlordId },
      });

      // Credit the landlord the net amount
      await tx.landlordWallet.update({
        where: { id: wallet.id },
        data: { balance: { increment: netAmount } }
      });

      await tx.landlordWalletEntry.create({
        data: {
          walletId: wallet.id,
          type: 'rent_credit',
          amount: netAmount,
          description: 'Rent payment received',
          referenceId: leaseId,
        }
      });

      // Record the platform fee
      await tx.platformFee.create({
        data: {
          landlordId,
          type: 'success_fee',
          amount: successFee,
          status: 'paid',
          referenceId: leaseId,
        }
      });

      // We don't necessarily expose the deduction explicitly in the ledger as a negative line 
      // if we credit them net directly, but for transparency we can add an informational entry.
      await tx.landlordWalletEntry.create({
        data: {
          walletId: wallet.id,
          type: 'platform_fee_deduction',
          amount: -successFee,
          description: 'Platform success fee (5%) deducted from rent',
          referenceId: leaseId,
        }
      });

      return { creditedAmount: netAmount, feeDeducted: successFee };
    });
  }

  private serialize(wallet: any) {
    return {
      id: wallet.id,
      balance: wallet.balance,
      pendingBalance: wallet.pendingBalance,
      entries: wallet.entries.map((entry: any) => ({ ...entry, createdAt: entry.createdAt.toISOString() })),
    };
  }
}

export const landlordWalletService = new LandlordWalletService();
