import { prisma } from '../lib/prisma';

const RNLP_MONTHS = 6;

export class RnlpService {
  async getOrCreateForTenant(tenantId: string) {
    const existing = await prisma.rnlpContract.findFirst({
      where: { tenantId, status: { in: ['active', 'completed'] } },
      include: { instalments: { orderBy: { installmentNumber: 'asc' } } },
    });
    if (existing) return existing;

    const rental = await prisma.rental.findFirst({
      where: { tenantId, status: 'active' },
      include: { property: true },
      orderBy: { createdAt: 'desc' },
    });
    if (!rental || rental.property.deposit <= 0) return null;

    const financedAmount = rental.property.deposit;
    return prisma.$transaction(async (tx) => {
      const monthly = Math.floor(financedAmount / RNLP_MONTHS);
      const remainder = financedAmount - monthly * RNLP_MONTHS;
      return tx.rnlpContract.create({
        data: {
          rentalId: rental.id,
          tenantId,
          financedAmount,
          remainingBalance: financedAmount,
          totalMonths: RNLP_MONTHS,
          monthlyInstalment: monthly,
          instalments: {
            create: Array.from({ length: RNLP_MONTHS }, (_, index) => ({
              installmentNumber: index + 1,
              amount: monthly + (index === RNLP_MONTHS - 1 ? remainder : 0),
              dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000 * (index + 1)),
            })),
          },
        },
        include: { instalments: { orderBy: { installmentNumber: 'asc' } } },
      });
    });
  }

  async markInstalmentPaid(instalmentId: string, providerTxId: string, amount: number) {
    return prisma.$transaction(async (tx) => {
      const instalment = await tx.rnlpInstalment.findUnique({
        where: { id: instalmentId },
        include: { contract: true },
      });
      if (!instalment || instalment.amount !== amount || instalment.status !== 'pending') return null;

      const updated = await tx.rnlpInstalment.update({
        where: { id: instalmentId },
        data: { status: 'paid', paidAt: new Date(), providerTxId },
      });
      const remainingBalance = Math.max(0, instalment.contract.remainingBalance - amount);
      await tx.rnlpContract.update({
        where: { id: instalment.contractId },
        data: { remainingBalance, status: remainingBalance === 0 ? 'completed' : 'active' },
      });
      return updated;
    });
  }
}

export const rnlpService = new RnlpService();