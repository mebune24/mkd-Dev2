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
import platformFeeRoutes from './routes/platformFees';
import commissionRoutes  from './routes/commissions';

const BASE = '/api';

app.use(`${BASE}/auth`,          authRoutes);
app.use(`${BASE}/users`,         userRoutes);
app.use(`${BASE}/properties`,    propertyRoutes);
app.use(`${BASE}/applications`,  applicationRoutes);
app.use(`${BASE}/platform-fees`, platformFeeRoutes);
app.use(`${BASE}/commissions`,   commissionRoutes);

// ── Health ────────────────────────────────────
app.get(`${BASE}/health`, (_req, res) => {
  res.json({ status: 'ok', message: 'Space Rentals API is running' });
});

// ── Start ─────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Space Rentals API running on port ${PORT}`);
});

export { app };
