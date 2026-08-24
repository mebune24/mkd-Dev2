import { prisma } from '../lib/prisma';
import { Prisma } from '@prisma/client';

export class ApplicationRepository {
  async findByTenant(tenantId: string) {
    return prisma.application.findMany({
      where: { tenantId },
      include: { property: true },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async findByProperty(propertyId: string) {
    return prisma.application.findMany({
      where: { propertyId },
      include: { tenant: { select: { id: true, name: true, email: true } } },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async findByLandlord(landlordId: string) {
    return prisma.application.findMany({
      where: { property: { landlordId } },
      include: {
        property: true,
        tenant: { select: { id: true, name: true, email: true } },
      },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async findById(id: string) {
    return prisma.application.findUnique({
      where: { id },
      include: { property: true, tenant: { select: { id: true, name: true, email: true } } },
    });
  }

  async create(data: Prisma.ApplicationCreateInput) {
    return prisma.application.create({ data });
  }

  async update(id: string, data: Prisma.ApplicationUpdateInput) {
    return prisma.application.update({ where: { id }, data });
  }

  async countByPropertyAndTenant(propertyId: string, tenantId: string) {
    return prisma.application.count({
      where: {
        propertyId,
        tenantId,
        status: { notIn: ['rejected', 'withdrawn'] },
      },
    });
  }
}

export const applicationRepository = new ApplicationRepository();
