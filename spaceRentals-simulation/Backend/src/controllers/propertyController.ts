import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, assertOwnerOrAdmin } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// GET /api/properties
// Public — everyone can browse available properties.
// ──────────────────────────────────────────────
export const getProperties = async (req: AuthRequest, res: Response) => {
  try {
    const properties = await prisma.property.findMany({
      where: { status: 'available' },
      include: {
        landlord: { select: { id: true, name: true } },
        propertyVerification: { select: { status: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(properties);
  } catch (error) {
    console.error('[getProperties]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// GET /api/properties/:id
// Public — anyone can view a single property.
// ──────────────────────────────────────────────
export const getPropertyById = async (req: AuthRequest, res: Response) => {
  try {
    const property = await prisma.property.findUnique({
      where: { id: req.params.id },
      include: {
        landlord: { select: { id: true, name: true } },
        propertyVerification: true,
      },
    });
    if (!property) return res.status(404).json({ message: 'Property not found.' });
    return res.json(property);
  } catch (error) {
    console.error('[getPropertyById]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// GET /api/properties/mine
// Landlord: their own listings only.
// ──────────────────────────────────────────────
export const getMyProperties = async (req: AuthRequest, res: Response) => {
  try {
    const properties = await prisma.property.findMany({
      where: { landlordId: req.user!.userId },
      include: { propertyVerification: true },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(properties);
  } catch (error) {
    console.error('[getMyProperties]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/properties
// Landlord only.
// ──────────────────────────────────────────────
export const createProperty = async (req: AuthRequest, res: Response) => {
  try {
    const { title, description, location, monthlyRent, deposit, amenities, images } = req.body;

    if (!title || !description || !location || !monthlyRent || !deposit) {
      return res.status(400).json({ message: 'title, description, location, monthlyRent, and deposit are required.' });
    }

    const property = await prisma.property.create({
      data: {
        landlordId: req.user!.userId,
        title,
        description,
        location,
        monthlyRent: Number(monthlyRent),
        deposit: Number(deposit),
        amenities: JSON.stringify(amenities ?? []),
        images: JSON.stringify(images ?? []),
        status: 'draft', // starts as draft; must be verified before going live
      },
    });
    return res.status(201).json(property);
  } catch (error) {
    console.error('[createProperty]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// PATCH /api/properties/:id
// Landlord: can only edit their own property.
// ──────────────────────────────────────────────
export const updateProperty = async (req: AuthRequest, res: Response) => {
  try {
    const property = await prisma.property.findUnique({ where: { id: req.params.id } });
    if (!property) return res.status(404).json({ message: 'Property not found.' });

    // Object-level authorization
    if (!assertOwnerOrAdmin(req, res, property.landlordId)) return;

    const { title, description, location, monthlyRent, deposit, amenities, images, status } = req.body;

    const updated = await prisma.property.update({
      where: { id: req.params.id },
      data: {
        ...(title && { title }),
        ...(description && { description }),
        ...(location && { location }),
        ...(monthlyRent && { monthlyRent: Number(monthlyRent) }),
        ...(deposit && { deposit: Number(deposit) }),
        ...(amenities && { amenities: JSON.stringify(amenities) }),
        ...(images && { images: JSON.stringify(images) }),
        ...(status && { status }),
      },
    });
    return res.json(updated);
  } catch (error) {
    console.error('[updateProperty]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// DELETE /api/properties/:id
// Landlord: their own. Admin: any.
// ──────────────────────────────────────────────
export const deleteProperty = async (req: AuthRequest, res: Response) => {
  try {
    const property = await prisma.property.findUnique({ where: { id: req.params.id } });
    if (!property) return res.status(404).json({ message: 'Property not found.' });
    if (!assertOwnerOrAdmin(req, res, property.landlordId)) return;

    await prisma.property.delete({ where: { id: req.params.id } });
    return res.json({ message: 'Property deleted.' });
  } catch (error) {
    console.error('[deleteProperty]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
