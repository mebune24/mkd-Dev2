import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import { AuthRequest } from '../middleware/authMiddleware';
import crypto from 'crypto';

const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// GET /api/commissions/wallet   (agent: own ledger + available balance)
// This delegates to userController's getAgentWallet via the route;
// here we add the withdraw initiation.
// ──────────────────────────────────────────────

// ──────────────────────────────────────────────
// POST /api/commissions/withdraw   (agent only)
// Initiates a Mobile Money withdrawal for AVAILABLE commissions.
// Idempotency prevents duplicate withdrawals.
// ──────────────────────────────────────────────
export const requestWithdrawal = async (req: AuthRequest, res: Response) => {
  try {
    const { amount, phoneNumber } = req.body;
    if (!amount || !phoneNumber) {
      return res.status(400).json({ message: 'amount and phoneNumber are required.' });
    }

    const agentId = req.user!.userId;

    const requestedAmount = Number(amount);
    if (!Number.isInteger(requestedAmount) || requestedAmount <= 0) {
      return res.status(400).json({ message: 'amount must be a positive integer.' });
    }

    // Create a withdrawal ledger entry with a unique idempotency key
    const idempotencyKey = `withdrawal_${agentId}_${Date.now()}_${uuidv4()}`;

    const withdrawal = await prisma.$transaction(async (tx) => {
      const available = await tx.agentTransaction.findMany({
        where: { agentId, status: 'available' },
        orderBy: { createdAt: 'asc' },
      });
      let remaining = requestedAmount;
      for (const commission of available) {
        if (remaining <= 0) break;
        const reserved = Math.min(commission.amount, remaining);
        await tx.agentTransaction.update({ where: { id: commission.id }, data: { status: 'processing' } });
        remaining -= reserved;
      }
      if (remaining > 0) {
        throw { status: 400, message: 'Insufficient balance.' };
      }
      return tx.agentTransaction.create({
        data: {
          agentId,
          type: 'withdrawal',
          amount: -requestedAmount,
          status: 'processing',
          sourceEvent: 'withdrawal_request',
          idempotencyKey,
        },
      });
    });

    return res.status(201).json({ message: 'Withdrawal initiated.', withdrawal });
  } catch (error) {
    console.error('[requestWithdrawal]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/commissions/webhook
// Payment provider confirms the withdrawal succeeded or failed.
// Idempotent — duplicate webhooks are safely ignored.
// ──────────────────────────────────────────────
export const commissionWebhook = async (req: AuthRequest, res: Response) => {
  try {
    const secret = process.env.COMMISSION_WEBHOOK_SECRET;
    const signature = req.headers['x-commission-signature'] as string;
    if (!secret || !signature) return res.status(401).json({ message: 'Invalid webhook signature.' });
    const expected = crypto.createHmac('sha256', secret).update(JSON.stringify(req.body)).digest('hex');
    if (signature.length !== expected.length || !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) {
      return res.status(401).json({ message: 'Invalid webhook signature.' });
    }
    const { idempotencyKey, status } = req.body; // status: "paid" | "failed"
    if (!idempotencyKey || !status) {
      return res.status(400).json({ message: 'idempotencyKey and status are required.' });
    }

    const tx = await prisma.agentTransaction.findUnique({ where: { idempotencyKey } });
    if (!tx) return res.status(404).json({ message: 'Transaction not found.' });

    // Idempotency guard
    if (tx.status === 'paid' || tx.status === 'failed') {
      return res.status(200).json({ message: 'Already processed.' });
    }

    await prisma.agentTransaction.update({
      where: { idempotencyKey },
      data: { status: ['paid', 'failed'].includes(status) ? status : 'failed' },
    });

    if (status === 'paid') {
      await prisma.agentTransaction.updateMany({
        where: { agentId: tx.agentId, type: 'commission', status: 'processing', referenceId: tx.id },
        data: { status: 'paid' },
      });
    } else if (status === 'failed') {
      await prisma.agentTransaction.updateMany({
        where: { agentId: tx.agentId, type: 'commission', status: 'processing', referenceId: tx.id },
        data: { status: 'available', referenceId: null },
      });
    }

    return res.json({ message: 'Webhook processed.' });
  } catch (error) {
    console.error('[commissionWebhook]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
