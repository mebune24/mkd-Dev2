import { prisma } from '../lib/prisma';

export class RentalService {
  async getAll() {
    return prisma.rental.findMany({
      include: { property: true, tenant: true, landlord: true, lease: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getTenantRentals(tenantId: string) {
    return prisma.rental.findMany({
      where: { tenantId },
      include: { property: true, landlord: true, lease: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getLandlordRentals(landlordId: string) {
    return prisma.rental.findMany({
      where: { landlordId },
      include: { property: true, tenant: true, lease: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getById(id: string, userId: string, role: string) {
    const rental = await prisma.rental.findUnique({
      where: { id },
      include: { property: true, tenant: true, landlord: true, lease: true, platformFees: true },
    });
    if (!rental) throw { status: 404, message: 'Rental not found.' };
    const isParty = rental.tenantId === userId || rental.landlordId === userId;
    if (!isParty && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    return rental;
  }

  async endRental(id: string, userId: string, role: string) {
    const rental = await prisma.rental.findUnique({ where: { id } });
    if (!rental) throw { status: 404, message: 'Rental not found.' };
    if (rental.landlordId !== userId && role !== 'admin') {
      throw { status: 403, message: 'Only the landlord or admin can end a rental.' };
    }
    if (rental.status !== 'active') {
      throw { status: 400, message: 'Rental is not active.' };
    }
    return prisma.rental.update({
      where: { id },
      data: { status: 'ended', endedAt: new Date() },
    });
  }
}

export const rentalService = new RentalService();
