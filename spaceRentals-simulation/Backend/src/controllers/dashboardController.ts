import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { prisma } from '../lib/prisma';
import { cacheGet, cacheSet } from '../config/redis';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[DashboardController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

export const getLandlordDashboardStats = async (req: AuthRequest, res: Response) => {
  try {
    const landlordId = req.user!.userId;
    const cacheKey = `dashboard:landlord:${landlordId}`;

    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.setHeader('X-Cache', 'HIT');
      return res.json(JSON.parse(cached));
    }

    const monthStart = new Date();
    monthStart.setUTCDate(1);
    monthStart.setUTCHours(0, 0, 0, 0);
    const historyStart = new Date(monthStart);
    historyStart.setUTCMonth(historyStart.getUTCMonth() - 5);

    const [properties, applications, rentals, successfulPayments, pendingPayments, historicalPayments, openMaintenance, unreadMessages, recentApplications, recentRentals, recentMessages] = await Promise.all([
      prisma.property.groupBy({
        by: ['status'],
        where: { landlordId },
        _count: { id: true },
      }),
      prisma.application.groupBy({
        by: ['status'],
        where: { property: { landlordId } },
        _count: { id: true },
      }),
      prisma.rental.findMany({
        where: { landlordId },
        select: { propertyId: true, status: true, monthlyRent: true },
      }),
      prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          status: 'successful',
          createdAt: { gte: monthStart },
          lease: { landlordId },
        },
      }),
      prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          status: { in: ['pending', 'processing', 'created'] },
          lease: { landlordId },
        },
      }),
      prisma.payment.findMany({
        where: { status: 'successful', createdAt: { gte: historyStart }, lease: { landlordId } },
        select: { amount: true, createdAt: true },
        orderBy: { createdAt: 'asc' },
      }),
      prisma.maintenanceRequest.count({
        where: {
          rental: { landlordId },
          status: { in: ['open', 'acknowledged', 'in_progress'] },
        },
      }),
      prisma.message.count({
        where: { receiverId: landlordId, readAt: null },
      }),
      prisma.application.findMany({
        where: { property: { landlordId } },
        select: { id: true, status: true, submittedAt: true, tenant: { select: { name: true } }, property: { select: { title: true } } },
        orderBy: { submittedAt: 'desc' },
        take: 5,
      }),
      prisma.rental.findMany({
        where: { landlordId },
        select: { id: true, status: true, createdAt: true, property: { select: { title: true } } },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
      prisma.message.findMany({
        where: { receiverId: landlordId },
        select: { id: true, body: true, createdAt: true, sender: { select: { name: true } } },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
    ]);

    const countByStatus = (rows: Array<{ status: string; _count: { id: number } }>) =>
      Object.fromEntries(rows.map((row) => [row.status, row._count.id]));
    const propertyCounts = countByStatus(properties);
    const applicationCounts = countByStatus(applications);
    const activeRentals = rentals.filter((rental) => rental.status === 'active');
    const rentedProperties = new Set(
      rentals.filter((rental) => rental.status === 'active').map((rental) => rental.propertyId),
    ).size;
    const rentableProperties = (propertyCounts.available ?? 0) +
      (propertyCounts.rented ?? 0) + (propertyCounts.reserved ?? 0);
    const totalProperties = Object.values(propertyCounts).reduce((sum, count) => sum + count, 0);
    const expectedMonthlyRent = activeRentals.reduce((sum, rental) => sum + rental.monthlyRent, 0);
    const monthlyCollections = new Map<string, number>();
    for (let offset = 0; offset < 6; offset += 1) {
      const month = new Date(historyStart);
      month.setUTCMonth(historyStart.getUTCMonth() + offset);
      monthlyCollections.set(month.toISOString().slice(0, 7), 0);
    }
    for (const payment of historicalPayments) {
      const key = payment.createdAt.toISOString().slice(0, 7);
      monthlyCollections.set(key, (monthlyCollections.get(key) ?? 0) + payment.amount);
    }

    const stats = {
      generatedAt: new Date().toISOString(),
      properties: {
        total: totalProperties,
        byStatus: propertyCounts,
        activeListings: propertyCounts.available ?? 0,
        rented: propertyCounts.rented ?? rentedProperties,
      },
      applications: {
        total: Object.values(applicationCounts).reduce((sum, count) => sum + count, 0),
        byStatus: applicationCounts,
        pending: (applicationCounts.submitted ?? 0) + (applicationCounts.under_review ?? 0),
      },
      occupancy: {
        occupiedProperties: rentedProperties,
        rentableProperties,
        occupancyRate: rentableProperties === 0 ? 0 : Number(((rentedProperties / rentableProperties) * 100).toFixed(1)),
        expectedMonthlyRent,
      },
      finance: {
        collectedThisMonth: successfulPayments._sum.amount ?? 0,
        pendingAmount: pendingPayments._sum.amount ?? 0,
        monthlyCollections: Array.from(monthlyCollections, ([month, amount]) => ({ month, amount })),
      },
      activeRentals: activeRentals.length,
      openMaintenance,
      unreadMessages,
      recentActivity: [
        ...recentApplications.map((application) => ({
          type: 'application',
          id: application.id,
          status: application.status,
          title: 'Rental application',
          description: `${application.tenant.name} applied for ${application.property.title}`,
          createdAt: application.submittedAt,
        })),
        ...recentRentals.map((rental) => ({
          type: 'rental',
          id: rental.id,
          status: rental.status,
          title: 'Rental update',
          description: rental.property.title,
          createdAt: rental.createdAt,
        })),
        ...recentMessages.map((message) => ({
          type: 'message',
          id: message.id,
          status: 'unread',
          title: `Message from ${message.sender.name}`,
          description: message.body,
          createdAt: message.createdAt,
        })),
      ].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()).slice(0, 8),
    };

    // Cache the aggregates for 5 minutes (300 seconds)
    await cacheSet(cacheKey, JSON.stringify(stats), 300);

    res.setHeader('X-Cache', 'MISS');
    return res.json(stats);
  } catch (err) {
    return handle(res, err);
  }
};
