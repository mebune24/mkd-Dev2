import { propertyRepository } from '../repositories/PropertyRepository';
import { prisma } from '../lib/prisma';
import { Property } from '@prisma/client';
import { cacheGet, cacheSet, clearCacheByPattern } from '../config/redis';
import { latLngToCell, gridDisk } from 'h3-js';
import { emitPropertyFeedUpdated } from '../socket';

const H3_RESOLUTION = 7; // Approx 5km area hexagon

export class PropertyService {
  async getAll(page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;
    const cacheKey = `properties:all:page${page}:limit${limit}`;
    const cached = await cacheGet(cacheKey);
    if (cached) return JSON.parse(cached);

    const [data, total] = await Promise.all([
      prisma.property.findMany({
        where: { status: { in: ['available', 'rented'] } },
        skip, take: limit,
        include: { landlord: { select: { id: true, name: true } }, propertyVerification: { select: { status: true, level: true } } },
        orderBy: [
          { premiumBoostUntil: { sort: 'desc', nulls: 'last' } },
          { createdAt: 'desc' },
        ],
      }),
      prisma.property.count(),
    ]);
    
    const result = { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    await cacheSet(cacheKey, JSON.stringify(result), 300); // 5 minutes cache
    return result;
  }

  // Fast H3-based geospatial search
  async searchNearby(latitude: number, longitude: number, radiusKm: number) {
    // Determine how many rings to search based on radius. At res 7, 1 ring is approx 3-5km.
    const rings = radiusKm > 5 ? 2 : 1; 
    const userHex = latLngToCell(latitude, longitude, H3_RESOLUTION);
    const surroundingHexagons = gridDisk(userHex, rings);

    return prisma.property.findMany({
      where: { 
        status: 'available', 
        h3Index: { in: surroundingHexagons }
      },
      include: { landlord: { select: { id: true, name: true } }, propertyVerification: { select: { status: true, level: true } } },
    });
  }

  async getById(id: string) {
    const cacheKey = `properties:id:${id}`;
    const cached = await cacheGet(cacheKey);
    if (cached) return JSON.parse(cached);

    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };

    await cacheSet(cacheKey, JSON.stringify(property), 600); // 10 minutes cache
    return property;
  }

  async getMyProperties(landlordId: string) {
    return propertyRepository.findByLandlord(landlordId);
  }

  async create(
    landlordId: string,
    data: Record<string, unknown>,
  ) {
    const { title, description, location, monthlyRent, deposit, amenities, images, videoUrls,
      bedrooms, bathrooms, areaSqM, furnished, parkingSpaces, hasWater, hasElectricity,
      isFenced, closeToRoad, securityMeans, category, latitude, longitude,
      acquisitionSource, acquisitionAgentId } = data as any;
    if (!title || !description || !location || !monthlyRent || !deposit) {
      throw { status: 400, message: 'title, description, location, monthlyRent, and deposit are required.' };
    }
    const result = await propertyRepository.create({
      landlord: { connect: { id: landlordId } },
      title: String(title),
      description: String(description),
      location: String(location),
      monthlyRent: Number(monthlyRent),
      deposit: Number(deposit),
      amenities: JSON.stringify(amenities ?? []),
      images: JSON.stringify(images ?? []),
      videoUrls: JSON.stringify(videoUrls ?? []),
      status: 'draft',
      bedrooms: bedrooms ? Number(bedrooms) : 0,
      bathrooms: bathrooms ? Number(bathrooms) : 0,
      areaSqM: areaSqM ? Number(areaSqM) : 0,
      furnished: !!furnished,
      parkingSpaces: parkingSpaces ? Number(parkingSpaces) : 0,
      hasWater: !!hasWater,
      hasElectricity: !!hasElectricity,
      isFenced: !!isFenced,
      closeToRoad: !!closeToRoad,
      securityMeans: securityMeans ? String(securityMeans) : 'None',
      category: category ? String(category) : 'Apartment',
      latitude: latitude ? Number(latitude) : undefined,
      longitude: longitude ? Number(longitude) : undefined,
      h3Index: (latitude && longitude) ? latLngToCell(Number(latitude), Number(longitude), H3_RESOLUTION) : undefined,
      acquisitionSource: acquisitionSource ? String(acquisitionSource) : 'LANDLORD',
      acquisitionAgentId: acquisitionAgentId ? String(acquisitionAgentId) : undefined,
    });
    await clearCacheByPattern('properties:*');
    await clearCacheByPattern(`dashboard:landlord:${landlordId}`);
    emitPropertyFeedUpdated(result.id);
    return result;
  }

  async update(
    id: string,
    requestingUserId: string,
    requestingUserRole: string,
    data: Record<string, unknown>,
  ) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== requestingUserId && requestingUserRole !== 'admin') {
      throw { status: 403, message: 'Forbidden: You do not own this property.' };
    }
    const updateData: Record<string, unknown> = {};
    const { title, description, location, monthlyRent, deposit, amenities, images, videoUrls, status, latitude, longitude,
      bedrooms, bathrooms, areaSqM, furnished, parkingSpaces, hasWater, hasElectricity, isFenced, closeToRoad,
      securityMeans, category } = data as any;
    if (title !== undefined) updateData.title = String(title);
    if (description !== undefined) updateData.description = String(description);
    if (location !== undefined) updateData.location = String(location);
    if (monthlyRent !== undefined) updateData.monthlyRent = Number(monthlyRent);
    if (deposit !== undefined) updateData.deposit = Number(deposit);
    if (amenities !== undefined) updateData.amenities = JSON.stringify(amenities);
    if (images !== undefined) updateData.images = JSON.stringify(images);
    if (videoUrls !== undefined) updateData.videoUrls = JSON.stringify(videoUrls);
    if (bedrooms !== undefined) updateData.bedrooms = Number(bedrooms);
    if (bathrooms !== undefined) updateData.bathrooms = Number(bathrooms);
    if (areaSqM !== undefined) updateData.areaSqM = Number(areaSqM);
    if (furnished !== undefined) updateData.furnished = Boolean(furnished);
    if (parkingSpaces !== undefined) updateData.parkingSpaces = Number(parkingSpaces);
    if (hasWater !== undefined) updateData.hasWater = Boolean(hasWater);
    if (hasElectricity !== undefined) updateData.hasElectricity = Boolean(hasElectricity);
    if (isFenced !== undefined) updateData.isFenced = Boolean(isFenced);
    if (closeToRoad !== undefined) updateData.closeToRoad = Boolean(closeToRoad);
    if (securityMeans !== undefined) updateData.securityMeans = String(securityMeans);
    if (category !== undefined) updateData.category = String(category);
    if (status && ['draft', 'available', 'auto_unpublished'].includes(String(status))) {
      updateData.status = String(status);
    } else if (status) {
      throw { status: 400, message: 'Invalid property status.' };
    }
    if (monthlyRent !== undefined && (!Number.isInteger(Number(monthlyRent)) || Number(monthlyRent) <= 0)) {
      throw { status: 400, message: 'monthlyRent must be a positive integer.' };
    }
    if (deposit !== undefined && (!Number.isInteger(Number(deposit)) || Number(deposit) < 0)) {
      throw { status: 400, message: 'deposit must be a non-negative integer.' };
    }
    if (latitude !== undefined) updateData.latitude = Number(latitude);
    if (longitude !== undefined) updateData.longitude = Number(longitude);

    const numericFields: Array<[string, unknown, number]> = [
      ['bedrooms', bedrooms, 0],
      ['bathrooms', bathrooms, 0],
      ['areaSqM', areaSqM, 0],
      ['parkingSpaces', parkingSpaces, 0],
    ];
    for (const [field, value, minimum] of numericFields) {
      if (value !== undefined && (!Number.isFinite(Number(value)) || Number(value) < minimum)) {
        throw { status: 400, message: `${field} must be a valid non-negative number.` };
      }
    }
    if (latitude !== undefined && (!Number.isFinite(Number(latitude)) || Number(latitude) < -90 || Number(latitude) > 90)) {
      throw { status: 400, message: 'latitude must be between -90 and 90.' };
    }
    if (longitude !== undefined && (!Number.isFinite(Number(longitude)) || Number(longitude) < -180 || Number(longitude) > 180)) {
      throw { status: 400, message: 'longitude must be between -180 and 180.' };
    }
    if (Object.keys(updateData).length === 0) {
      throw { status: 400, message: 'At least one property field is required.' };
    }

    // Recompute H3 index if coordinates are updated
    const finalLat = updateData.latitude !== undefined ? updateData.latitude as number : property.latitude;
    const finalLng = updateData.longitude !== undefined ? updateData.longitude as number : property.longitude;
    if (finalLat && finalLng) {
      updateData.h3Index = latLngToCell(finalLat, finalLng, H3_RESOLUTION);
    }
    
    const result = await propertyRepository.update(id, updateData);
    await clearCacheByPattern('properties:*');
    await clearCacheByPattern(`dashboard:landlord:${property.landlordId}`);
    emitPropertyFeedUpdated(id);
    return result;
  }

  async delete(id: string, requestingUserId: string, requestingUserRole: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== requestingUserId && requestingUserRole !== 'admin') {
      throw { status: 403, message: 'Forbidden.' };
    }
    const activeRental = await prisma.rental.findFirst({
      where: { propertyId: id },
      select: { status: true },
    });
    if (activeRental?.status === 'active') {
      throw { status: 409, message: 'Properties with active rentals cannot be deleted.' };
    }
    await propertyRepository.delete(id);
    await clearCacheByPattern('properties:*');
    await clearCacheByPattern(`dashboard:landlord:${property.landlordId}`);
    return { message: 'Property deleted.' };
  }

  async publish(id: string, userId: string, role: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== userId && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    if (property.status === 'rented' || property.status === 'reserved') {
      throw { status: 409, message: 'This property is not available for publishing.' };
    }
    const result = await propertyRepository.update(id, { status: 'available', lastConfirmedAvailableAt: new Date() });
    await clearCacheByPattern('properties:*');
    await clearCacheByPattern(`dashboard:landlord:${property.landlordId}`);
    emitPropertyFeedUpdated(id);
    return result;
  }

  async unpublish(id: string, userId: string, role: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== userId && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    const result = await propertyRepository.update(id, { status: 'draft' });
    await clearCacheByPattern('properties:*');
    await clearCacheByPattern(`dashboard:landlord:${property.landlordId}`);
    emitPropertyFeedUpdated(id);
    return result;
  }

  async confirmAvailability(id: string, userId: string, role: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== userId && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    const result = await propertyRepository.update(id, { lastConfirmedAvailableAt: new Date() });
    await clearCacheByPattern(`dashboard:landlord:${property.landlordId}`);
    return result;
  }

  async search(params: { q?: string; category?: string; minRent?: number; maxRent?: number; bedrooms?: number; page?: number; limit?: number; latitude?: number; longitude?: number }) {
    const { q, category, minRent, maxRent, bedrooms, page = 1, limit = 20, latitude, longitude } = params;
    
    const cacheKey = `properties:search:${JSON.stringify(params)}`;
    const cached = await cacheGet(cacheKey);
    if (cached) return JSON.parse(cached);

    const skip = (page - 1) * limit;
    const where: any = { status: 'available' };
    if (category && category !== 'All') where.category = category;
    if (bedrooms) where.bedrooms = { gte: Number(bedrooms) };
    if (minRent || maxRent) where.monthlyRent = {};
    if (minRent) where.monthlyRent.gte = Number(minRent);
    if (maxRent) where.monthlyRent.lte = Number(maxRent);
    if (q) {
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { location: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }
    
    // H3 Geospatial restriction if latitude and longitude are provided
    if (latitude && longitude) {
      const userHex = latLngToCell(Number(latitude), Number(longitude), H3_RESOLUTION);
      const surroundingHexagons = gridDisk(userHex, 1);
      where.h3Index = { in: surroundingHexagons };
    }
    
    const [data, total] = await Promise.all([
      prisma.property.findMany({
        where,
        skip, take: limit,
        include: { landlord: { select: { id: true, name: true } }, propertyVerification: { select: { status: true, level: true } } },
        orderBy: [
          { premiumBoostUntil: { sort: 'desc', nulls: 'last' } },
          { createdAt: 'desc' },
        ],
      }),
      prisma.property.count({ where }),
    ]);
    
    const result = { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    await cacheSet(cacheKey, JSON.stringify(result), 300); // 5 mins cache
    return result;
  }
}

export const propertyService = new PropertyService();
