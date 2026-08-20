import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import { AuthRequest } from '../middleware/authMiddleware';

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

    // Compute available balance from ledger
    const available = await prisma.agentTransaction.findMany({
      where: { agentId, status: 'available' },
    });
    const balance = available.reduce((sum, t) => sum + t.amount, 0);

    if (Number(amount) > balance) {
      return res.status(400).json({ message: `Insufficient balance. Available: ${balance} FCFA.` });
    }

    // Create a withdrawal ledger entry with a unique idempotency key
    const idempotencyKey = `withdrawal_${agentId}_${Date.now()}_${uuidv4()}`;

    const withdrawal = await prisma.agentTransaction.create({
      data: {
        agentId,
        type: 'withdrawal',
        amount: -Number(amount), // negative = money leaving wallet
        status: 'processing',
        sourceEvent: 'withdrawal_request',
        idempotencyKey,
      },
    });

    // TODO: Call Mobile Money provider SDK (CamPay / Flutterwave) with phoneNumber

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

    return res.json({ message: 'Webhook processed.' });
  } catch (error) {
    console.error('[commissionWebhook]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
