import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { prisma } from '../lib/prisma';
import { userRepository } from '../repositories/UserRepository';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[AdminController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/admin/reports/summary
export const getReportsSummary = async (_req: AuthRequest, res: Response) => {
  try {
    const [
      totalUsers,
      totalProperties,
      totalApplications,
      totalLeases,
      totalRentals,
      totalRevenue,
      activeSubscriptions,
      pendingKyc,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.property.count(),
      prisma.application.count(),
      prisma.lease.count(),
      prisma.rental.count(),
      prisma.transaction.aggregate({ _sum: { amount: true }, where: { status: 'SUCCESSFUL' } }),
      prisma.subscription.count({ where: { status: 'active' } }),
      prisma.agentVerification.count({ where: { status: 'pending' } }),
    ]);

    const usersByRole = await prisma.user.groupBy({
      by: ['role'],
      _count: { id: true },
    });

    return res.json({
      users: { total: totalUsers, byRole: usersByRole },
      properties: { total: totalProperties },
      applications: { total: totalApplications },
      leases: { total: totalLeases },
      rentals: { total: totalRentals },
      revenue: { totalXAF: totalRevenue._sum.amount ?? 0 },
      subscriptions: { active: activeSubscriptions },
      kyc: { pending: pendingKyc },
    });
  } catch (err) { return handle(res, err); }
};

// GET /api/admin/transactions
export const getAdminTransactions = async (req: AuthRequest, res: Response) => {
  try {
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 50;
    const skip = (page - 1) * limit;
    const [transactions, total] = await Promise.all([
      prisma.transaction.findMany({
        include: { user: { select: { id: true, name: true, email: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.transaction.count(),
    ]);
    return res.json({ transactions, total, page, limit });
  } catch (err) { return handle(res, err); }
};

// GET /api/admin/users
export const getAdminUsers = async (req: AuthRequest, res: Response) => {
  try {
    const { role, status, search } = req.query;
    const where: any = {};
    if (role) where.role = String(role);
    if (status) where.status = String(status);
    if (search) where.OR = [
      { name: { contains: String(search), mode: 'insensitive' } },
      { email: { contains: String(search), mode: 'insensitive' } },
    ];
    const users = await userRepository.findMany({ where, orderBy: { createdAt: 'desc' } });
    return res.json(users);
  } catch (err) { return handle(res, err); }
};

// PATCH /api/admin/users/:id/suspend
export const adminSuspendUser = async (req: AuthRequest, res: Response) => {
  try {
    const user = await userRepository.findById(String(req.params.id));
    if (!user) return res.status(404).json({ message: 'User not found.' });
    const updated = await userRepository.update(String(req.params.id), { status: 'suspended' });
    return res.json({ message: 'User suspended.', user: updated });
  } catch (err) { return handle(res, err); }
};

// PATCH /api/admin/users/:id/activate
export const adminActivateUser = async (req: AuthRequest, res: Response) => {
  try {
    const user = await userRepository.findById(String(req.params.id));
    if (!user) return res.status(404).json({ message: 'User not found.' });
    const updated = await userRepository.update(String(req.params.id), { status: 'active' });
    return res.json({ message: 'User activated.', user: updated });
  } catch (err) { return handle(res, err); }
};

// GET /api/admin/properties
export const getAdminProperties = async (_req: AuthRequest, res: Response) => {
  try {
    const properties = await prisma.property.findMany({
      include: { landlord: { select: { id: true, name: true, email: true } }, propertyVerification: true },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(properties);
  } catch (err) { return handle(res, err); }
};
