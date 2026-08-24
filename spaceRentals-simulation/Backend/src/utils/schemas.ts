import { z } from 'zod';

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(2),
    email: z.string().email(),
    password: z.string().min(6),
    role: z.enum(['landlord', 'tenant', 'agent']),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(1),
  }),
});

export const createPropertySchema = z.object({
  body: z.object({
    title: z.string().min(5),
    description: z.string().min(10),
    location: z.string(),
    monthlyRent: z.number().positive(),
    deposit: z.number().nonnegative(),
    amenities: z.any().optional(),
    images: z.any().optional(),
    latitude: z.number().optional(),
    longitude: z.number().optional(),
  }),
});

export const initiatePaymentSchema = z.object({
  body: z.object({
    amount: z.number().positive(),
    email: z.string().email(),
    phoneNumber: z.string().optional(),
    message: z.string(),
    referenceType: z.enum(['LEASE', 'PLATFORM_FEE']),
    referenceId: z.string().uuid(),
    redirectUrl: z.string().url().optional(),
    paymentMethod: z.string(),
  }),
});
