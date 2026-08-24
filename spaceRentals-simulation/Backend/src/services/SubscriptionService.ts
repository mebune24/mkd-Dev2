import { prisma } from '../lib/prisma';
import { fapshiPaymentService } from './FapshiPaymentService';

// ── Subscription Plans (static config) ──────────────────────────
const PLANS = [
  {
    id: 'starter',
    name: 'Starter',
    price: 5000,
    listingLimit: 3,
    features: ['3 active listings', 'Basic support', 'Application management'],
  },
  {
    id: 'growth',
    name: 'Growth',
    price: 15000,
    listingLimit: 10,
    features: ['10 active listings', 'Priority support', 'Application management', 'Analytics'],
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 30000,
    listingLimit: 50,
    features: ['50 active listings', 'Dedicated support', 'Full analytics', 'Agent marketplace'],
  },
];

export class SubscriptionService {
  getPlans() {
    return PLANS;
  }

  getPlanById(planId: string) {
    const plan = PLANS.find(p => p.id === planId);
    if (!plan) throw { status: 404, message: 'Subscription plan not found.' };
    return plan;
  }

  async getStatus(landlordId: string) {
    const subscription = await prisma.subscription.findFirst({
      where: { landlordId },
      orderBy: { createdAt: 'desc' },
    });
    if (!subscription) {
      return { status: 'none', subscription: null, plans: PLANS };
    }
    const plan = PLANS.find(p => p.id === subscription.planId);
    return { status: subscription.status, subscription, plan };
  }

  async initiate(
    landlordId: string,
    params: { planId: string; phoneNumber: string; email: string; paymentMethod: string },
  ) {
    const { planId, phoneNumber, email, paymentMethod } = params;
    const plan = this.getPlanById(planId);

    // Check existing active subscription
    const existing = await prisma.subscription.findFirst({
      where: { landlordId, status: { in: ['active', 'grace_period'] } },
      orderBy: { createdAt: 'desc' },
    });
    if (existing) {
      throw { status: 409, message: 'You already have an active subscription.' };
    }

    // Create subscription record (pending payment)
    const expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 1);

    const subscription = await prisma.subscription.create({
      data: {
        landlord: { connect: { id: landlordId } },
        planId,
        status: 'active', // will be validated by webhook in production
        expiresAt,
      },
    });

    // Initiate Fapshi payment
    const payment = await fapshiPaymentService.initiatePayment({
      userId: landlordId,
      amount: plan.price,
      email,
      phoneNumber,
      message: `Space Rentals ${plan.name} Subscription`,
      referenceType: 'PLATFORM_FEE',
      referenceId: subscription.id,
      paymentMethod,
    });

    return { subscription, payment };
  }
}

export const subscriptionService = new SubscriptionService();
