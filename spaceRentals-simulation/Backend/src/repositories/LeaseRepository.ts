import { prisma } from '../lib/prisma';
import { Prisma } from '@prisma/client';

export class LeaseRepository {
  async findById(id: string) {
    return prisma.lease.findUnique({
      where: { id },
      include: { application: true, property: true, payments: true, tenant: true, landlord: true },
    });
  }

  async findByApplicationId(applicationId: string) {
    return prisma.lease.findUnique({
      where: { applicationId },
      include: { application: true, property: true, tenant: true, landlord: true },
    });
  }

  async findByTenant(tenantId: string) {
    return prisma.lease.findMany({
      where: { tenantId },
      include: { property: true, landlord: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByLandlord(landlordId: string) {
    return prisma.lease.findMany({
      where: { landlordId },
      include: { property: true, tenant: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: Prisma.LeaseCreateInput) {
    return prisma.lease.create({ data, include: { property: true, tenant: true, landlord: true } });
  }

  async update(id: string, data: Prisma.LeaseUpdateInput) {
    return prisma.lease.update({
      where: { id },
      data,
      include: { property: true, tenant: true, landlord: true },
    });
  }
}

export const leaseRepository = new LeaseRepository();
