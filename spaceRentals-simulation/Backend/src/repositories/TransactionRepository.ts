import { prisma } from '../lib/prisma';
import { Prisma } from '@prisma/client';

export class TransactionRepository {
  async create(data: Prisma.TransactionCreateInput) {
    return prisma.transaction.create({ data });
  }

  async findById(id: string) {
    return prisma.transaction.findUnique({ where: { id } });
  }

  async findByGatewayTxId(gatewayTxId: string) {
    return prisma.transaction.findUnique({ where: { gatewayTxId } });
  }

  async findByUserId(userId: string) {
    return prisma.transaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByReference(referenceType: string, referenceId: string) {
    return prisma.transaction.findMany({
      where: { referenceType, referenceId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateByGatewayTxId(
    gatewayTxId: string,
    data: Prisma.TransactionUpdateInput,
  ) {
    return prisma.transaction.update({ where: { gatewayTxId }, data });
  }

  async findAll(args?: Prisma.TransactionFindManyArgs) {
    return prisma.transaction.findMany(args);
  }
}

export const transactionRepository = new TransactionRepository();
