import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, assertOwnerOrAdmin } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// GET /api/applications
// Tenant: their own applications.
// Landlord: applications on their properties.
// Admin: all applications.
// ──────────────────────────────────────────────
export const getApplications = async (req: AuthRequest, res: Response) => {
  try {
    const { userId, role } = req.user!;

    const applications = await prisma.application.findMany({
      where:
        role === 'tenant'
          ? { tenantId: userId }
          : role === 'landlord'
          ? { property: { landlordId: userId } }
          : undefined, // admin sees all
      include: {
        property: { select: { id: true, title: true, location: true, monthlyRent: true, landlordId: true } },
        tenant: { select: { id: true, name: true, email: true } },
      },
      orderBy: { submittedAt: 'desc' },
    });
    return res.json(applications);
  } catch (error) {
    console.error('[getApplications]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// GET /api/applications/:id
// Returns one application if the caller has access to it.
// ──────────────────────────────────────────────
export const getApplicationById = async (req: AuthRequest, res: Response) => {
  try {
    const application = await prisma.application.findUnique({
      where: { id: req.params.id },
      include: {
        property: true,
        tenant: { select: { id: true, name: true, email: true } },
      },
    });
    if (!application) return res.status(404).json({ message: 'Application not found.' });

    // Object-level: tenant who applied OR landlord who owns the property OR admin
    const { userId, role } = req.user!;
    const isParty =
      role === 'admin' ||
      application.tenantId === userId ||
      application.property.landlordId === userId;

    if (!isParty) {
      return res.status(403).json({ message: 'You do not have permission to view this application.' });
    }
    return res.json(application);
  } catch (error) {
    console.error('[getApplicationById]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/applications   (tenant only)
// ──────────────────────────────────────────────
export const createApplication = async (req: AuthRequest, res: Response) => {
  try {
    const { propertyId, coverLetter } = req.body;
    if (!propertyId) return res.status(400).json({ message: 'propertyId is required.' });

    const property = await prisma.property.findUnique({ where: { id: propertyId } });
    if (!property) return res.status(404).json({ message: 'Property not found.' });
    if (property.status !== 'available') {
      return res.status(400).json({ message: 'This property is not available for applications.' });
    }

    // Prevent duplicate applications
    const existing = await prisma.application.findFirst({
      where: { tenantId: req.user!.userId, propertyId },
    });
    if (existing) {
      return res.status(409).json({ message: 'You have already submitted an application for this property.' });
    }

    const application = await prisma.application.create({
      data: {
        tenantId: req.user!.userId,
        propertyId,
        coverLetter,
        status: 'submitted',
      },
    });
    return res.status(201).json(application);
  } catch (error) {
    console.error('[createApplication]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// PATCH /api/applications/:id/status
// Landlord: can approve / reject.
// Tenant: can withdraw.
// Admin: can do anything.
// ──────────────────────────────────────────────
export const updateApplicationStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { status } = req.body;
    if (!status) return res.status(400).json({ message: 'status is required.' });

    const application = await prisma.application.findUnique({
      where: { id: req.params.id },
      include: { property: true },
    });
    if (!application) return res.status(404).json({ message: 'Application not found.' });

    const { userId, role } = req.user!;

    // Landlord transitions: under_review, approved, rejected
    const landlordAllowed = ['under_review', 'approved', 'rejected'];
    // Tenant transitions: withdrawn
    const tenantAllowed = ['withdrawn'];

    if (role === 'landlord') {
      if (application.property.landlordId !== userId) {
        return res.status(403).json({ message: 'You do not own this property.' });
      }
      if (!landlordAllowed.includes(status)) {
        return res.status(400).json({ message: `Landlords may only set status to: ${landlordAllowed.join(', ')}` });
      }
    } else if (role === 'tenant') {
      if (application.tenantId !== userId) {
        return res.status(403).json({ message: 'This is not your application.' });
      }
      if (!tenantAllowed.includes(status)) {
        return res.status(400).json({ message: `Tenants may only set status to: ${tenantAllowed.join(', ')}` });
      }
    } else if (role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden.' });
    }

    const updated = await prisma.application.update({
      where: { id: req.params.id },
      data: { status },
    });
    return res.json(updated);
  } catch (error) {
    console.error('[updateApplicationStatus]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
