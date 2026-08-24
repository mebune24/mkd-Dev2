import axios from 'axios';
import { transactionRepository } from '../repositories/TransactionRepository';

const FAPSHI_API_URL = process.env.FAPSHI_API_URL || 'https://live.fapshi.com';
const FAPSHI_API_USER = process.env.FAPSHI_API_USER || '';
const FAPSHI_API_KEY = process.env.FAPSHI_API_KEY || '';

interface FapshiPaymentResponse {
  message: string;
  transId: string;
  link?: string;
}

interface FapshiStatusResponse {
  message: string;
  transId: string;
  status: string;
  amount: number;
  medium?: string;
}

/**
 * FapshiPaymentService
 *
 * All interactions with the Fapshi payment gateway go through this service.
 *
 * HOW IT WORKS (plain language):
 * 1. initiatePayment() — Creates a new payment link for a user.
 *    The user is redirected to Fapshi to pay via MTN or Orange Money.
 *    We immediately log a "PENDING" transaction in our own DB.
 *
 * 2. getPaymentStatus() — Checks the current status of any payment.
 *    Called from the webhook handler after Fapshi notifies us.
 *
 * 3. handleWebhook() — When Fapshi sends a payment success/failure notification
 *    to our /api/payments/webhook endpoint, we update the transaction in our DB.
 *
 * 4. initiatePayout() — Send money OUT (e.g., landlord withdrawals).
 */
export class FapshiPaymentService {
  private headers() {
    return {
      apiuser: FAPSHI_API_USER,
      apikey: FAPSHI_API_KEY,
      'Content-Type': 'application/json',
    };
  }

  /**
   * Initiates a payment request with Fapshi.
   * Returns the payment link and the Fapshi transactionId.
   */
  async initiatePayment(params: {
    userId: string;
    amount: number;
    email: string;
    phoneNumber?: string;
    message: string;
    referenceType: string;
    referenceId: string;
    redirectUrl?: string;
    paymentMethod: string;
  }) {
    const { userId, amount, email, phoneNumber, message, referenceType, referenceId, redirectUrl, paymentMethod } = params;

    const payload: Record<string, unknown> = {
      amount,
      email,
      message,
      ...(phoneNumber && { phone: phoneNumber }),
      ...(redirectUrl && { redirectUrl }),
    };

    let response: FapshiPaymentResponse;
    try {
      const { data } = await axios.post<FapshiPaymentResponse>(
        `${FAPSHI_API_URL}/initiate-pay`,
        payload,
        { headers: this.headers() },
      );
      response = data;
    } catch (err: any) {
      const msg = err?.response?.data?.message || 'Failed to initiate payment with Fapshi.';
      throw { status: 502, message: msg };
    }

    // Persist the pending transaction to our database
    const transaction = await transactionRepository.create({
      user: { connect: { id: userId } },
      amount,
      currency: 'XAF',
      paymentMethod,
      transactionType: 'PAYMENT',
      referenceType,
      referenceId,
      gatewayTxId: response.transId,
      status: 'PENDING',
      metadata: JSON.stringify(response),
    });

    return {
      transactionId: transaction.id,
      gatewayTxId: response.transId,
      paymentLink: response.link,
    };
  }

  /**
   * Checks the live status of a payment from Fapshi.
   */
  async getPaymentStatus(gatewayTxId: string): Promise<FapshiStatusResponse> {
    try {
      const { data } = await axios.get<FapshiStatusResponse>(
        `${FAPSHI_API_URL}/payment-status/${gatewayTxId}`,
        { headers: this.headers() },
      );
      return data;
    } catch (err: any) {
      const msg = err?.response?.data?.message || 'Failed to fetch payment status.';
      throw { status: 502, message: msg };
    }
  }

  /**
   * Handles an incoming Fapshi webhook.
   * Fapshi POSTs to /api/payments/webhook when payment status changes.
   * We update the transaction in our DB and return the updated record.
   */
  async handleWebhook(payload: { transId: string; status: string; [key: string]: unknown }) {
    const { transId, status } = payload;

    const existing = await transactionRepository.findByGatewayTxId(transId);
    if (!existing) {
      console.warn(`[FapshiWebhook] Unknown transId: ${transId}`);
      return null;
    }

    // FSM Idempotency Check: only allow transition from PENDING
    if (existing.status === 'SUCCESSFUL' || existing.status === 'FAILED') {
      console.log(`[FapshiWebhook] Duplicate or invalid transition for ${transId}. Current state: ${existing.status}`);
      return existing; // Return early, idempotency enforced
    }

    const mappedStatus = status === 'SUCCESSFUL' ? 'SUCCESSFUL' : 'FAILED';

    return transactionRepository.updateByGatewayTxId(transId, {
      status: mappedStatus,
      metadata: JSON.stringify(payload),
    });
  }

  /**
   * Initiates a payout to a mobile money number.
   * Used for agent commission withdrawals / landlord payouts.
   */
  async initiatePayout(params: {
    userId: string;
    amount: number;
    phone: string;
    message: string;
    referenceType: string;
    referenceId: string;
    paymentMethod: string;
  }) {
    const { userId, amount, phone, message, referenceType, referenceId, paymentMethod } = params;

    let response: FapshiPaymentResponse;
    try {
      const { data } = await axios.post<FapshiPaymentResponse>(
        `${FAPSHI_API_URL}/payout`,
        { amount, phone, message },
        { headers: this.headers() },
      );
      response = data;
    } catch (err: any) {
      const msg = err?.response?.data?.message || 'Payout request failed.';
      throw { status: 502, message: msg };
    }

    const transaction = await transactionRepository.create({
      user: { connect: { id: userId } },
      amount,
      currency: 'XAF',
      paymentMethod,
      transactionType: 'PAYOUT',
      referenceType,
      referenceId,
      gatewayTxId: response.transId,
      status: 'PENDING',
      metadata: JSON.stringify(response),
    });

    return { transactionId: transaction.id, gatewayTxId: response.transId };
  }
}

export const fapshiPaymentService = new FapshiPaymentService();
