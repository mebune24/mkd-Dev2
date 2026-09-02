import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import morgan from 'morgan';

dotenv.config();

const app = express();

// ── Security middleware ────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') ?? '*',
  credentials: true,
}));

app.use(morgan('[:date[iso]] :method :url :status :response-time ms - :res[content-length]'));

// ── Rate limiting ──────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  message: { message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Auth endpoints get a stricter limiter
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { message: 'Too many authentication attempts, please try again later.' },
});

// Admin routes: moderate limit (protects bulk DB queries)
const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 60,
  message: { message: 'Too many admin requests, please slow down.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Payment routes: strict limit to prevent fraud / duplicate charges
const paymentLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { message: 'Too many payment requests, please wait before trying again.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Agent routes: moderate limit
const agentLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { message: 'Too many agent requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(express.json({ limit: '10mb' }));

// ── Routes ────────────────────────────────────────────────────
import authRoutes          from './routes/auth';
import userRoutes          from './routes/users';
import propertyRoutes      from './routes/properties';
import applicationRoutes   from './routes/applications';
import paymentRoutes       from './routes/payments';
import leaseRoutes         from './routes/leases';
import rentalRoutes        from './routes/rentals';
import agentRoutes         from './routes/agents';
import subscriptionRoutes  from './routes/subscriptions';
import commissionRoutes    from './routes/commissions';
import platformFeeRoutes   from './routes/platformFees';
import adminRoutes         from './routes/admin';
import dashboardRoutes     from './routes/dashboard';
import disputeRoutes       from './routes/disputes';
import storageRoutes       from './routes/storage';
import auditLogRoutes      from './routes/auditLogs';
import notificationRoutes  from './routes/notifications';
import maintenanceRoutes   from './routes/maintenance';
import reviewRoutes        from './routes/reviews';
import { globalErrorHandler } from './middleware/errorMiddleware';
import { startBackgroundWorkers } from './workers';

const BASE = '/api';

app.use(`${BASE}/auth`,          authLimiter, authRoutes);
app.use(`${BASE}/users`,         userRoutes);
app.use(`${BASE}/properties`,    propertyRoutes);
app.use(`${BASE}/applications`,  applicationRoutes);
app.use(`${BASE}/payments`,      paymentLimiter, paymentRoutes);
app.use(`${BASE}/leases`,        leaseRoutes);
app.use(`${BASE}/rentals`,       rentalRoutes);
app.use(`${BASE}/agents`,        agentLimiter, agentRoutes);
app.use(`${BASE}/subscriptions`, subscriptionRoutes);
app.use(`${BASE}/commissions`,   commissionRoutes);
app.use(`${BASE}/platform-fees`, platformFeeRoutes);
app.use(`${BASE}/admin`,         adminLimiter, adminRoutes);
app.use(`${BASE}/dashboard`,     dashboardRoutes);
app.use(`${BASE}/disputes`,      disputeRoutes);
app.use(`${BASE}/storage`,       storageRoutes);
app.use(`${BASE}/audit-logs`,    auditLogRoutes);
app.use(`${BASE}/notifications`, notificationRoutes);
app.use(`${BASE}/maintenance`,   maintenanceRoutes);
app.use(`${BASE}/reviews`,       reviewRoutes);

// ── Health ────────────────────────────────────────────────────
app.get(`${BASE}/health`, (_req, res) => {
  res.json({
    status: 'ok',
    message: 'Space Rentals API is running',
    version: '2.0.0',
    architecture: 'MVC (Controller → Service → Repository)',
    paymentGateway: 'Fapshi (MTN & Orange Money)',
    routes: [
      'auth', 'users', 'properties', 'applications', 'payments',
      'leases', 'rentals', 'agents', 'subscriptions', 'commissions',
      'platform-fees', 'admin', 'notifications', 'maintenance', 'reviews',
    ],
  });
});

// ── 404 catch-all ─────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ message: 'Route not found.' });
});

app.use(globalErrorHandler);

// ── Start ─────────────────────────────────────────────────────
const PORT = Number(process.env.PORT || 3000);
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Server] Space Rentals API running on port ${PORT}`);
  startBackgroundWorkers();
  console.log(`📐  Architecture : MVC (Controller → Service → Repository)`);
  console.log(`💳  Payments     : Fapshi (MTN / Orange Money)`);
  console.log(`🗄️   Database     : PostgreSQL (Prisma ORM)`);
  console.log(`🔒  Security     : Helmet + Rate Limiting`);
  console.log(`📦  Routes       : 15 feature groups registered (incl. storage + audit)\n`);
});

export { app };
