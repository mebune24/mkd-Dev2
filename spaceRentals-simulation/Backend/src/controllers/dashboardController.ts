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

    // Aggregate active listings
    const activeListings = await prisma.property.count({
      where: { landlordId, status: 'available' }
    });

    // Aggregate total applications
    const applications = await prisma.application.count({
      where: { property: { landlordId } }
    });

    // Aggregate total active leases / rentals
    const activeRentals = await prisma.lease.count({
      where: { property: { landlordId }, status: 'SIGNED' }
    });

    const stats = {
      activeListings,
      totalApplications: applications,
      activeRentals,
      timestamp: new Date().toISOString()
    };

    // Cache the aggregates for 5 minutes (300 seconds)
    await cacheSet(cacheKey, JSON.stringify(stats), 300);

    res.setHeader('X-Cache', 'MISS');
    return res.json(stats);
  } catch (err) {
    return handle(res, err);
  }
};
