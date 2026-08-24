import { prisma } from '../lib/prisma';
import { Prisma } from '@prisma/client';

export class LeaseRepository {
  async findById(id: string) {
    return prisma.lease.findUnique({
      where: { id },
      include: { application: true, property: true, payments: true },
    });
  }

  async findByApplicationId(applicationId: string) {
    return prisma.lease.findUnique({ where: { applicationId } });
  }

  async create(data: Prisma.LeaseCreateInput) {
    return prisma.lease.create({ data });
  }

  async update(id: string, data: Prisma.LeaseUpdateInput) {
    return prisma.lease.update({ where: { id }, data });
  }
}

export const leaseRepository = new LeaseRepository();
