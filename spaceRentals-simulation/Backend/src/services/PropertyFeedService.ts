import { prisma } from '../lib/prisma';

const parseList = (value: string): string[] => {
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed.filter((item) => typeof item === 'string' && item.trim()) : [];
  } catch {
    return [];
  }
};

export class PropertyFeedService {
  async getVideoFeed(page = 1, limit = 10, viewerId?: string) {
    const safePage = Math.max(1, page);
    const safeLimit = Math.min(Math.max(1, limit), 30);
    const where = { status: 'available' };

    const properties = await prisma.property.findMany({
        where,
        select: {
          id: true,
          title: true,
          description: true,
          location: true,
          category: true,
          monthlyRent: true,
          deposit: true,
          images: true,
          videoUrls: true,
          bedrooms: true,
          bathrooms: true,
          furnished: true,
          createdAt: true,
          updatedAt: true,
          landlord: { select: { id: true, name: true, avatarUrl: true } },
          propertyVerification: { select: { status: true, level: true } },
          _count: { select: { comments: true, likes: true, reshares: true } },
          likes: viewerId ? { where: { userId: viewerId }, select: { id: true } } : false,
          reshares: viewerId ? { where: { userId: viewerId }, select: { id: true } } : false,
        },
        orderBy: [
          { premiumBoostUntil: { sort: 'desc', nulls: 'last' } },
          { createdAt: 'desc' },
        ],
      });

    const videoProperties = properties
      .map((property) => ({ property, videoUrls: parseList(property.videoUrls) }))
      .filter(({ videoUrls }) => videoUrls.length > 0);
    const items = videoProperties
      .slice((safePage - 1) * safeLimit, safePage * safeLimit)
      .map(({ property, videoUrls }) => ({
        id: property.id,
        propertyId: property.id,
        title: property.title,
        description: property.description,
        location: property.location,
        category: property.category,
        monthlyRent: property.monthlyRent,
        deposit: property.deposit,
        images: parseList(property.images),
        videoUrls,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        furnished: property.furnished,
        landlord: property.landlord,
        engagement: {
          likes: property._count.likes,
          comments: property._count.comments,
          reshares: property._count.reshares,
          likedByMe: viewerId ? property.likes.length > 0 : false,
          resharedByMe: viewerId ? property.reshares?.length > 0 : false,
        },
        verification: property.propertyVerification,
        publishedAt: property.createdAt,
        updatedAt: property.updatedAt,
      }));

    return {
      items,
      page: safePage,
      limit: safeLimit,
      total: videoProperties.length,
      hasMore: safePage * safeLimit < videoProperties.length,
    };
  }
}

export const propertyFeedService = new PropertyFeedService();