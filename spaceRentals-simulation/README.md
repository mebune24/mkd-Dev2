# Space Rentals — Property Management & Rental Platform

Space Rentals is a modern peer-to-peer marketplace designed for Cameroon, bridging the gap between tenants, landlords, and field agents using **Mobile Money (MTN/Orange)**, **Fapshi**, and a strict state-machine-driven workflow.

---

## Codebase Architecture

The project is split into two primary environments: a **Flutter Mobile Frontend** and a **Node.js/Express/Prisma Backend**.

---

### 1. Backend Architecture (Node.js + Express + Prisma)

The backend is built around a production-grade **MVC** architecture. It uses **PostgreSQL** with **PostGIS** for spatial queries, **Fapshi** for Mobile Money (Momo) payments, and **Redis** for intelligent multi-layer caching.

#### Key System Design Patterns:
- **Finite State Machine (FSM):** Strict state transitions for Leases and Payments (`PENDING → SUCCESSFUL`), preventing double-processing.
- **Distributed Ledger:** Agent commissions are stored in an immutable ledger (`AgentTransaction` table) using double-entry accounting and Prisma `$transaction`.
- **Multi-Layer Redis Caching:** A Cache-Aside pattern for property search feeds and a `SCAN`-safe key invalidation strategy. See caching strategy below.
- **Idempotency Webhooks:** Fapshi webhook payloads are protected against duplicate processing via unique `gatewayTxId` tracking and Redis payment locks (`SET NX EX`).
- **Global Error Handling & Validation:** All incoming payloads are validated via `zod` schemas. Prisma errors (e.g. `P2025` Record Not Found) are automatically mapped to HTTP 404/400 codes.
- **Object-Level Access Control (OLAC):** Custom Express middlewares (`verifyPropertyOwnership`) ensure users can only modify their own assets.

#### Backend Directory Structure:
```text
Backend/
├── prisma/
│   └── schema.prisma              # PostgreSQL Schema with PostGIS extensions
├── src/
│   ├── config/
│   │   └── redis.ts               # Redis client + clearCacheByPattern() helper
│   ├── controllers/               # Thin HTTP handlers (Auth, Properties, Payments)
│   ├── services/                  # Core Business Logic & State Machines
│   ├── repositories/              # Database Access Layer (Prisma queries)
│   ├── routes/                    # Express Route Definitions
│   ├── middleware/                # Auth, Zod Validation, OLAC, Global Errors
│   ├── utils/                     # Zod Schemas
│   ├── lib/
│   │   └── prisma.ts              # Prisma Client with cache-invalidation Extension
│   ├── workers.ts                 # node-cron background workers (auto-unpublish)
│   └── index.ts                   # Express App Entrypoint
├── docker-compose.yml             # PostgreSQL + PostGIS Infrastructure
└── .env                           # Environment Variables
```

#### Redis Caching Strategy

| Layer / Resource           | Cache Type           | TTL           | Critical Note |
|---------------------------|----------------------|---------------|---------------|
| Property Search Feed      | Cache-Aside (Redis)  | 10 minutes    | Key includes city, price, type filters. Auto-invalidated on any Property mutation via Prisma extension. |
| Geographic Metadata       | Redis String         | 24–48 hours   | Cities, neighborhoods, regions. Manually invalidated on Admin update. |
| System Parameters         | Redis String         | 24–48 hours   | Subscription cost (5,000 FCFA), application fee (3,000 FCFA). |
| User Sessions / JWTs      | Redis String         | JWT expiry    | Destroyed immediately on password change or Admin ban. |
| Agent Ledger Balances     | **Do Not Cache**     | Live query    | Always hits PostgreSQL — prevents commission fraud. |
| Lease States & Signatures | **Do Not Cache**     | Live query    | PARTIALLY_SIGNED / SIGNED state must always be live. |
| Active Booking Overlaps   | **Do Not Cache**     | Live query    | Checked inside Prisma interactive transactions at checkout. |
| Mobile Money Webhook Lock | Redis NX Lock        | 30 seconds    | `SET payment_lock:tx_ref PROCESSING EX 30 NX` — prevents duplicate webhook processing. |

The Prisma Client Extension in `src/lib/prisma.ts` hooks into `create`, `update`, `delete`, `updateMany`, `deleteMany`, and `upsert` on the `Property` model and automatically calls `clearCacheByPattern('search:properties:*')`, so **no controller or service needs to manually invalidate cache**.

---

### 2. Frontend Architecture (Flutter)

The frontend is a cross-platform mobile application built with Flutter following **Feature-First Clean Architecture** with **Riverpod** for state management.

#### Frontend Directory Structure:
```text
space_rentals/lib/
├── features/
│   ├── admin/                # Admin dashboards and KYC management
│   ├── auth/                 # Login, Registration, OTP
│   ├── landlord/             # Landlord dashboard, Property creation
│   └── tenant/               # Tenant dashboard, Property search, Applications
├── core/                     # Core app configuration (Themes, Routing)
├── config/                   # Environment/API config
├── data/                     # Local data, dummy initializers
├── models/                   # Dart Data Classes (Property, User, Transaction)
├── providers/                # Global Riverpod State Providers
├── repositories/             # API/Network data fetching layer
├── services/                 # External service integrations
├── shared/                   # Shared utilities
├── widgets/                  # Reusable UI components (PropertyCards, Buttons)
└── main.dart                 # App Entrypoint
```

---

## Running the Application

### Prerequisites
- Docker & Docker Compose
- Node.js ≥ 18
- Redis (local or remote — set `REDIS_URL` in `.env`)
- Flutter SDK ≥ 3.x
- A connected Android/iOS device or emulator

### Backend (PostgreSQL + Redis + Node.js)
```bash
cd Backend

# 1. Start PostgreSQL (PostGIS) via Docker
docker-compose up -d

# 2. Install dependencies
npm install

# 3. Apply DB migrations & generate Prisma client
npx prisma migrate dev
npx prisma generate

# 4. Start the dev server
npm run dev
```

> **Redis**: Make sure Redis is running locally (`redis-server`) or update `REDIS_URL` in `.env` to point to your hosted Redis instance.

### Frontend (Flutter)
```bash
cd space_rentals

# 1. Fetch packages
flutter pub get

# 2. Run on a connected device
flutter run
```

---

## Environment Variables (Backend/.env)

| Variable         | Description                                 |
|-----------------|---------------------------------------------|
| `PORT`           | Express server port (default: 3000)         |
| `DATABASE_URL`   | PostgreSQL connection string                |
| `JWT_SECRET`     | Secret key for signing JWTs                 |
| `REDIS_URL`      | Redis connection URL (default: `redis://localhost:6379`) |
| `FAPSHI_API_URL` | Fapshi gateway URL                         |
| `FAPSHI_API_USER`| Fapshi API username                        |
| `FAPSHI_API_KEY` | Fapshi API key                             |
