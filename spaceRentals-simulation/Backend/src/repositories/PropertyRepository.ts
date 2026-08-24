import { prisma } from '../lib/prisma';
import { Prisma } from '@prisma/client';

export class PropertyRepository {
  async findAll() {
    return prisma.property.findMany({
      where: { status: 'available' },
      include: {
        landlord: { select: { id: true, name: true } },
        propertyVerification: { select: { status: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string) {
    return prisma.property.findUnique({
      where: { id },
      include: {
        landlord: { select: { id: true, name: true } },
        propertyVerification: true,
      },
    });
  }

  async findByLandlord(landlordId: string) {
    return prisma.property.findMany({
      where: { landlordId },
      include: { propertyVerification: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: Prisma.PropertyCreateInput) {
    return prisma.property.create({ data });
  }

  async update(id: string, data: Prisma.PropertyUpdateInput) {
    return prisma.property.update({ where: { id }, data });
  }

  async delete(id: string) {
    return prisma.property.delete({ where: { id } });
  }
}

export const propertyRepository = new PropertyRepository();
