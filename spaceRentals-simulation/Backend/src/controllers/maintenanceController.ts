import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';

// POST /api/maintenance — tenant submits a request
export const createMaintenanceRequest = async (req: Request, res: Response) => {
  try {
    const tenantId = (req as any).user.userId;
    const { rentalId, title, description, category, urgency, images } = req.body;
    if (!rentalId || !title || !description) {
      return res.status(400).json({ message: 'rentalId, title and description are required' }) as any;
    }
    const rental = await prisma.rental.findFirst({ where: { id: rentalId, tenantId } });
    if (!rental) return res.status(404).json({ message: 'Rental not found or not yours' }) as any;

    const request = await prisma.maintenanceRequest.create({
      data: {
        rentalId, tenantId, title, description,
        category: category ?? 'General',
        urgency: urgency ?? 'Normal',
        images: images ? JSON.stringify(images) : undefined,
      },
      include: { tenant: { select: { id: true, name: true } } },
    });
    res.status(201).json(request);
  } catch (e) {
    res.status(500).json({ message: 'Failed to create maintenance request' });
  }
};

// GET /api/maintenance — list based on role
export const getMaintenanceRequests = async (req: Request, res: Response) => {
  try {
    const { userId, role } = (req as any).user;
    const { status, limit = '20', page = '1' } = req.query;
    const take = Math.min(parseInt(limit as string), 50);
    const skip = (parseInt(page as string) - 1) * take;

    let where: any = {};
    if (role === 'tenant') {
      where.tenantId = userId;
    } else if (role === 'landlord') {
      const rentals = await prisma.rental.findMany({ where: { landlordId: userId }, select: { id: true } });
      where.rentalId = { in: rentals.map((r) => r.id) };
    }
    if (status) where.status = status;

    const [data, total] = await Promise.all([
      prisma.maintenanceRequest.findMany({
        where, skip, take,
        include: {
          tenant: { select: { id: true, name: true } },
          rental: { include: { property: { select: { id: true, title: true, location: true } } } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.maintenanceRequest.count({ where }),
    ]);
    res.json({ data, total, page: parseInt(page as string), limit: take });
  } catch (e) {
    res.status(500).json({ message: 'Failed to fetch maintenance requests' });
  }
};

// GET /api/maintenance/:id
export const getMaintenanceRequestById = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const request = await prisma.maintenanceRequest.findUnique({
      where: { id },
      include: {
        tenant: { select: { id: true, name: true } },
        rental: { include: { property: { select: { id: true, title: true } } } },
      },
    });
    if (!request) return res.status(404).json({ message: 'Not found' }) as any;
    res.json(request);
  } catch (e) {
    res.status(500).json({ message: 'Failed to fetch request' });
  }
};

// PATCH /api/maintenance/:id — landlord updates status / adds note
export const updateMaintenanceRequest = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const { status, landlordNote } = req.body;
    const data: any = {};
    if (status) {
      data.status = status;
      if (status === 'resolved') data.resolvedAt = new Date();
    }
    if (landlordNote !== undefined) data.landlordNote = landlordNote;
    const updated = await prisma.maintenanceRequest.update({ where: { id }, data });
    res.json(updated);
  } catch (e) {
    res.status(500).json({ message: 'Failed to update maintenance request' });
  }
};
