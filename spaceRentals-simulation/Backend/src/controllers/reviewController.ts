import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

// POST /api/reviews
export const createReview = async (req: Request, res: Response) => {
  try {
    const tenantId = (req as any).user.userId;
    const { propertyId, landlordId, rating, comment } = req.body;
    if (!propertyId || !landlordId || !rating) {
      return res.status(400).json({ message: 'propertyId, landlordId and rating are required' }) as any;
    }
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' }) as any;
    }
    // Ensure tenant has rented this property
    const rental = await prisma.rental.findFirst({ where: { tenantId, propertyId } });
    if (!rental) {
      return res.status(403).json({ message: 'You can only review properties you have rented' }) as any;
    }
    const review = await prisma.review.upsert({
      where: { propertyId_tenantId: { propertyId, tenantId } },
      create: { propertyId, tenantId, landlordId, rating, comment },
      update: { rating, comment, landlordId },
      include: { tenant: { select: { id: true, name: true, avatarUrl: true } } },
    });
    res.status(201).json(review);
  } catch (e) {
    res.status(500).json({ message: 'Failed to create review' });
  }
};

// GET /api/reviews/property/:propertyId
export const getPropertyReviews = async (req: Request, res: Response) => {
  try {
    const propertyId = req.params.propertyId as string;
    const { limit = '20', page = '1' } = req.query;
    const take = Math.min(parseInt(limit as string), 50);
    const skip = (parseInt(page as string) - 1) * take;

    const [reviews, total] = await Promise.all([
      prisma.review.findMany({
        where: { propertyId },
        skip, take,
        include: { tenant: { select: { id: true, name: true, avatarUrl: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.review.count({ where: { propertyId } }),
    ]);

    const avgRating = reviews.length > 0
      ? reviews.reduce((s, r) => s + r.rating, 0) / reviews.length
      : 0;

    res.json({ data: reviews, total, page: parseInt(page as string), limit: take, avgRating: Math.round(avgRating * 10) / 10 });
  } catch (e) {
    res.status(500).json({ message: 'Failed to fetch property reviews' });
  }
};

// GET /api/reviews/landlord/:landlordId
export const getLandlordReviews = async (req: Request, res: Response) => {
  try {
    const landlordId = req.params.landlordId as string;
    const reviews = await prisma.review.findMany({
      where: { landlordId },
      include: {
        tenant: { select: { id: true, name: true, avatarUrl: true } },
        property: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    const avgRating = reviews.length > 0
      ? reviews.reduce((s, r) => s + r.rating, 0) / reviews.length
      : 0;
    res.json({ data: reviews, total: reviews.length, avgRating: Math.round(avgRating * 10) / 10 });
  } catch (e) {
    res.status(500).json({ message: 'Failed to fetch landlord reviews' });
  }
};
