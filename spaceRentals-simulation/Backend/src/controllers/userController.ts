import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// GET /api/users  (admin only)
// ──────────────────────────────────────────────
export const getUsers = async (req: AuthRequest, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      select: { id: true, name: true, email: true, role: true, status: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(users);
  } catch (error) {
    console.error('[getUsers]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// PATCH /api/users/:id/status  (admin only)
// Toggle user active / suspended.
// ──────────────────────────────────────────────
export const updateUserStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { status } = req.body;
    if (!['active', 'suspended'].includes(status)) {
      return res.status(400).json({ message: 'status must be "active" or "suspended".' });
    }
    const updated = await prisma.user.update({
      where: { id: req.params.id },
      data: { status },
      select: { id: true, name: true, email: true, role: true, status: true },
    });
    return res.json(updated);
  } catch (error) {
    console.error('[updateUserStatus]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/users/kyc/agent  (agent: submit their verification)
// ──────────────────────────────────────────────
export const submitAgentKyc = async (req: AuthRequest, res: Response) => {
  try {
    const { documents } = req.body;
    if (!documents) return res.status(400).json({ message: 'documents are required.' });

    const kyc = await prisma.agentVerification.upsert({
      where: { agentId: req.user!.userId },
      update: { documents: JSON.stringify(documents), status: 'pending', submittedAt: new Date() },
      create: { agentId: req.user!.userId, documents: JSON.stringify(documents) },
    });
    return res.json(kyc);
  } catch (error) {
    console.error('[submitAgentKyc]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// GET /api/users/kyc/agents  (admin only)
// ──────────────────────────────────────────────
export const getAgentKycSubmissions = async (req: AuthRequest, res: Response) => {
  try {
    const submissions = await prisma.agentVerification.findMany({
      include: { agent: { select: { id: true, name: true, email: true } } },
      orderBy: { submittedAt: 'desc' },
    });
    return res.json(submissions);
  } catch (error) {
    console.error('[getAgentKycSubmissions]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// PATCH /api/users/kyc/agents/:id  (admin only)
// Approve or reject an agent KYC.
// ──────────────────────────────────────────────
export const reviewAgentKyc = async (req: AuthRequest, res: Response) => {
  try {
    const { status, adminNotes } = req.body;
    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'status must be "approved" or "rejected".' });
    }
    const updated = await prisma.agentVerification.update({
      where: { id: req.params.id },
      data: { status, adminNotes },
    });
    return res.json(updated);
  } catch (error) {
    console.error('[reviewAgentKyc]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// GET /api/users/wallet  (agent: view own ledger)
// ──────────────────────────────────────────────
export const getAgentWallet = async (req: AuthRequest, res: Response) => {
  try {
    const transactions = await prisma.agentTransaction.findMany({
      where: { agentId: req.user!.userId },
      orderBy: { createdAt: 'desc' },
    });

    const available = transactions
      .filter((t) => t.status === 'available')
      .reduce((sum, t) => sum + t.amount, 0);

    return res.json({ available, transactions });
  } catch (error) {
    console.error('[getAgentWallet]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
