import { propertyRepository } from '../repositories/PropertyRepository';
import { prisma } from '../lib/prisma';
import { Property } from '@prisma/client';

export class PropertyService {
  async getAll() {
    return propertyRepository.findAll();
  }

  // PostGIS spatial bounding-box query
  async searchNearby(latitude: number, longitude: number, radiusKm: number) {
    // ST_DWithin performs incredibly fast spatial bounding-box searches
    // 4326 is the WGS 84 spatial reference system (standard GPS coordinates)
    const radiusMeters = radiusKm * 1000;
    const properties = await prisma.$queryRaw<Property[]>`
      SELECT * FROM "Property"
      WHERE status = 'available'
      AND "latitude" IS NOT NULL 
      AND "longitude" IS NOT NULL
      AND ST_DWithin(
        ST_SetSRID(ST_MakePoint("longitude", "latitude"), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
        ${radiusMeters}
      );
    `;
    return properties;
  }

  async getById(id: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    return property;
  }

  async getMyProperties(landlordId: string) {
    return propertyRepository.findByLandlord(landlordId);
  }

  async create(
    landlordId: string,
    data: {
      title: string;
      description: string;
      location: string;
      monthlyRent: number;
      deposit: number;
      amenities?: unknown;
      images?: unknown;
    },
  ) {
    const { title, description, location, monthlyRent, deposit, amenities, images } = data;
    if (!title || !description || !location || !monthlyRent || !deposit) {
      throw { status: 400, message: 'title, description, location, monthlyRent, and deposit are required.' };
    }
    return propertyRepository.create({
      landlord: { connect: { id: landlordId } },
      title,
      description,
      location,
      monthlyRent: Number(monthlyRent),
      deposit: Number(deposit),
      amenities: JSON.stringify(amenities ?? {}),
      images: JSON.stringify(images ?? []),
      status: 'draft',
    });
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
    const { title, description, location, monthlyRent, deposit, amenities, images, status } = data;
    if (title) updateData.title = title as string;
    if (description) updateData.description = description as string;
    if (location) updateData.location = String(location);
    if (monthlyRent) updateData.monthlyRent = Number(monthlyRent);
    if (deposit) updateData.deposit = Number(deposit);
    if (amenities) updateData.amenities = JSON.stringify(amenities);
    if (images) updateData.images = JSON.stringify(images);
    if (status) updateData.status = String(status);
    return propertyRepository.update(id, updateData);
  }

  async delete(id: string, requestingUserId: string, requestingUserRole: string) {
    const property = await propertyRepository.findById(id);
    if (!property) throw { status: 404, message: 'Property not found.' };
    if (property.landlordId !== requestingUserId && requestingUserRole !== 'admin') {
      throw { status: 403, message: 'Forbidden.' };
    }
    await propertyRepository.delete(id);
    return { message: 'Property deleted.' };
  }
}

export const propertyService = new PropertyService();
