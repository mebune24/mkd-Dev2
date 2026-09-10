import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware';
import { prisma } from '../lib/prisma';
import { userRepository } from '../repositories/UserRepository';
import bcrypt from 'bcrypt';
import { auditLogService } from '../services/AuditLogService';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[AdminController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// GET /api/admin/overview
export const getAdminOverview = async (_req: AuthRequest, res: Response) => {
  try {
    const [usersByRole, totalUsers, suspendedUsers, pendingKyc, openDisputes, underReviewDisputes, properties, applications, leases, rentals, successfulRevenue, pendingPayments, openMaintenance, activeSubscriptions] = await Promise.all([
      prisma.user.groupBy({ by: ['role', 'status'], _count: { id: true } }),
      prisma.user.count(),
      prisma.user.count({ where: { status: 'suspended' } }),
      prisma.agentVerification.count({ where: { status: 'pending' } }),
      prisma.dispute.count({ where: { status: 'open' } }),
      prisma.dispute.count({ where: { status: 'under_review' } }),
      prisma.property.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.application.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.lease.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.rental.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.transaction.aggregate({ _sum: { amount: true }, where: { status: 'SUCCESSFUL' } }),
      prisma.payment.count({ where: { status: { in: ['pending', 'processing'] } } }),
      prisma.maintenanceRequest.count({ where: { status: { in: ['open', 'acknowledged', 'in_progress'] } } }),
      prisma.subscription.count({ where: { status: 'active' } }),
    ]);

    const countRole = (role: string, status?: string) => usersByRole.find((row) => row.role === role && (!status || row.status === status))?._count.id ?? 0;
    const groupCounts = (rows: Array<{ status: string; _count: { id: number } }>) => Object.fromEntries(rows.map((row) => [row.status, row._count.id]));

    return res.json({
      generatedAt: new Date().toISOString(),
      users: {
        total: totalUsers,
        suspended: suspendedUsers,
        tenants: countRole('tenant'),
        landlords: countRole('landlord'),
        agents: countRole('agent'),
        admins: countRole('admin'),
        active: totalUsers - suspendedUsers,
      },
      kyc: { pending: pendingKyc },
      disputes: { open: openDisputes, underReview: underReviewDisputes },
      properties: { byStatus: groupCounts(properties) },
      applications: { byStatus: groupCounts(applications) },
      leases: { byStatus: groupCounts(leases) },
      rentals: { byStatus: groupCounts(rentals) },
      finance: { successfulRevenueXaf: successfulRevenue._sum.amount ?? 0, pendingPayments },
      maintenance: { open: openMaintenance },
      subscriptions: { active: activeSubscriptions },
    });
  } catch (err) { return handle(res, err); }
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

    const [successfulTransactions, activeProperties, signedLeases, auditLogs, unresolvedDisputes] = await Promise.all([
      prisma.transaction.findMany({
        where: { status: 'SUCCESSFUL' },
        select: { amount: true, createdAt: true },
        orderBy: { createdAt: 'asc' },
      }),
      prisma.property.findMany({
        where: { status: { in: ['available', 'reserved', 'rented'] } },
        select: { category: true },
      }),
      prisma.lease.count({ where: { status: { in: ['signed', 'active'] } } }),
      (prisma as any).auditLog.count(),
      prisma.dispute.count({ where: { status: { not: 'resolved' } } }),
    ]);

    const monthlyRevenue = new Map<string, number>();
    for (const transaction of successfulTransactions) {
      const month = transaction.createdAt.toISOString().slice(0, 7);
      monthlyRevenue.set(month, (monthlyRevenue.get(month) ?? 0) + transaction.amount);
    }

    const listingsByCategory = new Map<string, number>();
    for (const property of activeProperties) {
      listingsByCategory.set(property.category, (listingsByCategory.get(property.category) ?? 0) + 1);
    }

    const usersByRole = await prisma.user.groupBy({
      by: ['role'],
      _count: { id: true },
    });

    return res.json({
      users: { total: totalUsers, byRole: usersByRole },
      properties: { total: totalProperties },
      activeListings: { total: activeProperties.length },
      applications: { total: totalApplications },
      leases: { total: totalLeases },
      rentals: { total: totalRentals },
      revenue: { totalXAF: totalRevenue._sum.amount ?? 0 },
      subscriptions: { active: activeSubscriptions },
      kyc: { pending: pendingKyc },
      monthlyRevenue: Array.from(monthlyRevenue, ([month, amount]) => ({ month, amount })),
      listingsByCategory: Array.from(listingsByCategory, ([category, count]) => ({ category, count })),
      compliance: {
        signedLeases,
        totalLeases,
        successfulPayments: successfulTransactions.length,
        auditLogs,
        unresolvedDisputes,
      },
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
      { phone: { contains: String(search), mode: 'insensitive' } },
    ];
    const users = await userRepository.findMany({ where, orderBy: { createdAt: 'desc' } });
    return res.json(users);
  } catch (err) { return handle(res, err); }
};

export const createAdminUser = async (req: AuthRequest, res: Response) => {
  try {
    const { name, email, temporaryPassword } = req.body;
    if (!name || !email || !temporaryPassword || temporaryPassword.length < 8) {
      return res.status(400).json({ message: 'name, email, and a password of at least 8 characters are required.' });
    }
    const existing = await userRepository.findByEmail(email);
    if (existing) return res.status(409).json({ message: 'Email is already in use.' });
    const user = await userRepository.create({
      name: String(name).trim(),
      email: String(email).trim().toLowerCase(),
      passwordHash: await bcrypt.hash(temporaryPassword, 12),
      role: 'admin',
      status: 'active',
    });
    await auditLogService.log({
      userId: req.user!.userId,
      action: 'admin.created',
      resourceId: user.id,
      resourceType: 'user',
      metadata: { email: user.email },
    });
    return res.status(201).json({ id: user.id, name: user.name, email: user.email, role: user.role, status: user.status });
  } catch (err) { return handle(res, err); }
};

export const bulkSuspendUsers = async (req: AuthRequest, res: Response) => {
  try {
    const ids = Array.isArray(req.body.userIds) ? req.body.userIds.map(String) : [];
    if (ids.length === 0 || ids.length > 100) return res.status(400).json({ message: 'userIds must contain between 1 and 100 users.' });
    const result = await prisma.user.updateMany({
      where: {
        id: { in: ids, not: req.user!.userId },
        role: { not: 'admin' },
        status: { not: 'suspended' },
      },
      data: { status: 'suspended' },
    });
    await auditLogService.log({
      userId: req.user!.userId,
      action: 'users.bulk_suspended',
      resourceId: req.user!.userId,
      resourceType: 'user_batch',
      metadata: { requestedIds: ids, updatedCount: result.count },
    });
    return res.json({ updatedCount: result.count });
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

// GET /api/admin/platform-fees
export const getAdminPlatformFees = async (_req: AuthRequest, res: Response) => {
  try {
    const fees = await prisma.platformFee.findMany({
      include: {
        landlord: { select: { id: true, name: true, email: true } },
        rental: {
          select: {
            id: true,
            property: { select: { id: true, title: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(fees);
  } catch (err) { return handle(res, err); }
};

// GET /api/admin/subscriptions
export const getAdminSubscriptions = async (_req: AuthRequest, res: Response) => {
  try {
    const subscriptions = await prisma.subscription.findMany({
      include: { landlord: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(subscriptions);
  } catch (err) { return handle(res, err); }
};
