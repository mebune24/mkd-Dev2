import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// ── Routes ────────────────────────────────────
import authRoutes        from './routes/auth';
import userRoutes        from './routes/users';
import propertyRoutes    from './routes/properties';
import applicationRoutes from './routes/applications';
import paymentRoutes     from './routes/payments';
import { globalErrorHandler } from './middleware/errorMiddleware';
import { startBackgroundWorkers } from './workers';

const BASE = '/api';

app.use(`${BASE}/auth`,         authRoutes);
app.use(`${BASE}/users`,        userRoutes);
app.use(`${BASE}/properties`,   propertyRoutes);
app.use(`${BASE}/applications`, applicationRoutes);
app.use(`${BASE}/payments`,     paymentRoutes);

// ── Health ────────────────────────────────────
app.get(`${BASE}/health`, (_req, res) => {
  res.json({
    status: 'ok',
    message: 'Space Rentals API is running',
    architecture: 'MVC (Controller → Service → Repository)',
    paymentGateway: 'Fapshi (MTN & Orange Money)',
  });
});

// ── 404 catch-all ─────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ message: 'Route not found.' });
});

app.use(globalErrorHandler);

// ── Start ─────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀  Space Rentals API running on port ${PORT}`);
  startBackgroundWorkers();
  console.log(`📐  Architecture : MVC`);
  console.log(`💳  Payments     : Fapshi (MTN / Orange Money)`);
  console.log(`🗄️   Database     : SQLite (Prisma ORM)\n`);
});

export { app };
