import { Request, Response } from 'express';
import crypto from 'crypto';
import { AuthRequest } from '../middleware/authMiddleware';
import { fapshiPaymentService } from '../services/FapshiPaymentService';
import { transactionRepository } from '../repositories/TransactionRepository';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[PaymentController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// POST /api/payments/initiate
export const initiatePayment = async (req: AuthRequest, res: Response) => {
  try {
    const { amount, email, phoneNumber, message, referenceType, referenceId, redirectUrl, paymentMethod } = req.body;
    if (!amount || !email || !message || !referenceType || !referenceId || !paymentMethod) {
      return res.status(400).json({ message: 'amount, email, message, referenceType, referenceId and paymentMethod are required.' });
    }
    const result = await fapshiPaymentService.initiatePayment({
      userId: req.user!.userId,
      amount: Number(amount),
      email,
      phoneNumber,
      message,
      referenceType,
      referenceId,
      redirectUrl,
      paymentMethod,
    });
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// POST /api/payments/payout
export const initiatePayout = async (req: AuthRequest, res: Response) => {
  try {
    const { amount, phone, message, referenceType, referenceId, paymentMethod } = req.body;
    if (!amount || !phone || !message || !referenceType || !referenceId || !paymentMethod) {
      return res.status(400).json({ message: 'amount, phone, message, referenceType, referenceId and paymentMethod are required.' });
    }
    const result = await fapshiPaymentService.initiatePayout({
      userId: req.user!.userId,
      amount: Number(amount),
      phone,
      message,
      referenceType,
      referenceId,
      paymentMethod,
    });
    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// GET /api/payments/status/:gatewayTxId
export const getPaymentStatus = async (req: AuthRequest, res: Response) => {
  try {
    const status = await fapshiPaymentService.getPaymentStatus(String(req.params.gatewayTxId));
    return res.json(status);
  } catch (err) { return handle(res, err); }
};

// GET /api/payments/transactions
export const getMyTransactions = async (req: AuthRequest, res: Response) => {
  try {
    const transactions = await transactionRepository.findByUserId(req.user!.userId);
    return res.json(transactions);
  } catch (err) { return handle(res, err); }
};

// POST /api/payments/webhook  (no auth — called by Fapshi)
export const fapshiWebhook = async (req: Request, res: Response) => {
  try {
    // Verify Fapshi webhook signature if secret is configured
    const webhookSecret = process.env.FAPSHI_WEBHOOK_SECRET;
    if (webhookSecret) {
      const signature = req.headers['x-fapshi-signature'] as string;
      if (!signature) {
        console.warn('[Webhook] Missing X-Fapshi-Signature header — rejecting request');
        return res.status(401).json({ message: 'Missing webhook signature.' });
      }
      const expectedSig = crypto
        .createHmac('sha256', webhookSecret)
        .update(JSON.stringify(req.body))
        .digest('hex');
      try {
        if (!crypto.timingSafeEqual(Buffer.from(signature, 'hex'), Buffer.from(expectedSig, 'hex'))) {
          console.warn('[Webhook] Invalid Fapshi signature — possible spoofed request');
          return res.status(401).json({ message: 'Invalid webhook signature.' });
        }
      } catch {
        return res.status(401).json({ message: 'Invalid webhook signature format.' });
      }
    } else {
      console.warn('[Webhook] FAPSHI_WEBHOOK_SECRET not set — signature verification skipped (unsafe for production!)');
    }

    const payload = req.body;
    if (!payload?.transId) {
      return res.status(400).json({ message: 'Invalid webhook payload.' });
    }
    const result = await fapshiPaymentService.handleWebhook(payload);
    if (!result) return res.status(404).json({ message: 'Transaction not found.' });
    console.log(`[Webhook] Updated transaction ${result.gatewayTxId} → ${result.status}`);
    return res.json({ received: true });
  } catch (err) { return handle(res, err); }
};
