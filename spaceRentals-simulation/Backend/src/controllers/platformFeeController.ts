import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';
import { AuthRequest, assertOwnerOrAdmin } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

// ──────────────────────────────────────────────
// GET /api/platform-fees  (admin: all, landlord: own)
// ──────────────────────────────────────────────
export const getPlatformFees = async (req: AuthRequest, res: Response) => {
  try {
    const { userId, role } = req.user!;
    const fees = await prisma.platformFee.findMany({
      where: role === 'admin' ? undefined : { landlordId: userId },
      orderBy: { createdAt: 'desc' },
    });
    return res.json(fees);
  } catch (error) {
    console.error('[getPlatformFees]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/platform-fees/:id/pay  (landlord: pay their own fee)
// In production, this would initiate a Mobile Money payment.
// The idempotencyKey prevents double-charges on retries.
// ──────────────────────────────────────────────
export const initiateFeePay = async (req: AuthRequest, res: Response) => {
  try {
    const fee = await prisma.platformFee.findUnique({ where: { id: String(req.params.id) } });
    if (!fee) return res.status(404).json({ message: 'Platform fee not found.' });
    if (!assertOwnerOrAdmin(req, res, fee.landlordId)) return;

    if (fee.status === 'paid') {
      return res.status(400).json({ message: 'This fee has already been paid.' });
    }
    if (fee.status === 'processing') {
      return res.status(400).json({ message: 'Payment is already being processed.' });
    }

    // Mark as processing; payment provider callback will mark as "paid"
    const updated = await prisma.platformFee.update({
      where: { id: String(req.params.id) },
      data: { status: 'processing' },
    });

    // TODO: call payment provider SDK here (Flutterwave / CamPay)
    return res.json({ message: 'Payment initiated.', fee: updated });
  } catch (error) {
    console.error('[initiateFeePay]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ──────────────────────────────────────────────
// POST /api/platform-fees/webhook
// Called by the payment provider after a payment completes.
// Idempotent: duplicate webhooks are safely ignored.
// ──────────────────────────────────────────────
export const feePaymentWebhook = async (req: AuthRequest, res: Response) => {
  try {
    const { providerTxId, feeId, status } = req.body;
    if (!providerTxId || !feeId || !status) {
      return res.status(400).json({ message: 'providerTxId, feeId, and status are required.' });
    }

    // Check the fee still exists and is in a processable state
    const fee = await prisma.platformFee.findUnique({ where: { id: feeId } });
    if (!fee) return res.status(404).json({ message: 'Platform fee not found.' });

    // Idempotency: if already paid, ignore the duplicate webhook
    if (fee.status === 'paid') {
      return res.status(200).json({ message: 'Already processed.' });
    }

    if (status === 'successful') {
      await prisma.platformFee.update({
        where: { id: feeId },
        data: { status: 'paid' },
      });
    } else {
      await prisma.platformFee.update({
        where: { id: feeId },
        data: { status: 'due' }, // revert to due so landlord can retry
      });
    }

    return res.json({ message: 'Webhook processed.' });
  } catch (error) {
    console.error('[feePaymentWebhook]', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
