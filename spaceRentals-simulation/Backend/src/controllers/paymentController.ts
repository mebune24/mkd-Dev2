import { Request, Response } from 'express';
import crypto from 'crypto';
import { AuthRequest } from '../middleware/authMiddleware';
import { fapshiPaymentService } from '../services/FapshiPaymentService';
import { transactionRepository } from '../repositories/TransactionRepository';
import { redisClient } from '../config/redis';
import { prisma } from '../lib/prisma';
import { hasVerifiedLandlordAccess } from '../middleware/authMiddleware';

const handle = (res: Response, err: any) => {
  const status = err?.status || 500;
  console.error('[PaymentController]', err);
  return res.status(status).json({ message: err?.message || 'Internal server error' });
};

// POST /api/payments/initiate
export const initiatePayment = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user!.role === 'landlord' && !(await hasVerifiedLandlordAccess(req.user!))) {
      return res.status(403).json({ message: 'Approved landlord verification is required before initiating payments.' });
    }
    const idempotencyKey = req.headers['idempotency-key'] as string;
    if (idempotencyKey) {
      const cached = await redisClient.get(`idempotency:payment:${idempotencyKey}`);
      if (cached) {
        return res.status(200).json(JSON.parse(cached));
      }
    }

    const { amount, email, phoneNumber, message, referenceType, referenceId, redirectUrl, paymentMethod } = req.body;
    if (!amount || !email || !message || !referenceType || !referenceId || !paymentMethod) {
      return res.status(400).json({ message: 'amount, email, message, referenceType, referenceId and paymentMethod are required.' });
    }
    const numericAmount = Number(amount);
    if (!Number.isInteger(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: 'amount must be a positive integer.' });
    }
    if (referenceType === 'LEASE') {
      const lease = await prisma.lease.findUnique({ where: { id: referenceId }, include: { property: true } });
      if (!lease || (lease.tenantId !== req.user!.userId && lease.landlordId !== req.user!.userId)) {
        return res.status(403).json({ message: 'You are not a party to this lease.' });
      }
      if (lease.status !== 'signed' || !lease.tenantSignedAt || !lease.landlordSignedAt) {
        return res.status(409).json({ message: 'Lease must be fully signed before payment.' });
      }
      if (numericAmount !== lease.property.deposit + lease.property.monthlyRent) {
        return res.status(400).json({ message: 'Payment amount does not match the lease terms.' });
      }
    } else if (referenceType === 'RNLP_INSTALMENT') {
      const instalment = await prisma.rnlpInstalment.findUnique({
        where: { id: referenceId },
        include: { contract: true },
      });
      if (!instalment || instalment.contract.tenantId !== req.user!.userId) {
        return res.status(403).json({ message: 'You cannot pay this RNLP instalment.' });
      }
      if (instalment.status !== 'pending' || numericAmount !== instalment.amount) {
        return res.status(409).json({ message: 'RNLP instalment is invalid or already processed.' });
      }
    } else {
      const fee = await prisma.platformFee.findUnique({ where: { id: referenceId } });
      if (!fee || (fee.landlordId !== req.user!.userId && req.user!.role !== 'admin')) {
        return res.status(403).json({ message: 'You cannot pay this platform fee.' });
      }
      if (fee.status !== 'due' || numericAmount !== fee.amount) {
        return res.status(409).json({ message: 'Platform fee is invalid or already processed.' });
      }
    }
    const result = await fapshiPaymentService.initiatePayment({
      userId: req.user!.userId,
      amount: numericAmount,
      email,
      phoneNumber,
      message,
      referenceType,
      referenceId,
      redirectUrl,
      paymentMethod,
    });

    if (idempotencyKey) {
      await redisClient.set(`idempotency:payment:${idempotencyKey}`, JSON.stringify(result), { EX: 86400 }); // 24 hours
    }

    return res.status(201).json(result);
  } catch (err) { return handle(res, err); }
};

// POST /api/payments/payout
export const initiatePayout = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user!.role === 'landlord' && !(await hasVerifiedLandlordAccess(req.user!))) {
      return res.status(403).json({ message: 'Approved landlord verification is required before requesting a payout.' });
    }
    const idempotencyKey = req.headers['idempotency-key'] as string;
    if (idempotencyKey) {
      const cached = await redisClient.get(`idempotency:payout:${idempotencyKey}`);
      if (cached) {
        return res.status(200).json(JSON.parse(cached));
      }
    }

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

    if (idempotencyKey) {
      await redisClient.set(`idempotency:payout:${idempotencyKey}`, JSON.stringify(result), { EX: 86400 });
    }

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

// GET /api/payments/landlord-transactions
export const getLandlordTransactions = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user!.role !== 'landlord' && req.user!.role !== 'admin') {
      return res.status(403).json({ message: 'Only landlords can view landlord payments.' });
    }
    if (!(await hasVerifiedLandlordAccess(req.user!))) {
      return res.status(403).json({ message: 'Approved landlord verification is required before viewing landlord payments.' });
    }
    return res.json(await transactionRepository.findByLandlordId(req.user!.userId));
  } catch (err) { return handle(res, err); }
};

// POST /api/payments/webhook  (no auth — called by Fapshi)
export const fapshiWebhook = async (req: Request, res: Response) => {
  try {
    // Verify Fapshi webhook signature strictly
    const webhookSecret = process.env.FAPSHI_WEBHOOK_SECRET;
    if (!webhookSecret) {
      console.error('[Webhook] FATAL: FAPSHI_WEBHOOK_SECRET is not configured in production.');
      return res.status(500).json({ message: 'Server configuration error.' });
    }

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
