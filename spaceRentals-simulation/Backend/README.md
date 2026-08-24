# SpaceRentals Backend

This is the backend for SpaceRentals, built with Node.js, Express, TypeScript, and Prisma.

## Prerequisites
- Node.js 22+
- PostgreSQL 15+
- Redis (optional, but recommended for caching)

## Features
- **MVC Architecture**: Clean separation of routes, controllers, services, and repositories.
- **Payments**: Integrated with Fapshi for MTN / Orange Money payments.
- **Security**: Configured with `helmet` and `express-rate-limit` for protection against attacks.
- **Caching**: Uses Redis for rapid data retrieval (safe fallback to DB if Redis is offline).

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Environment Variables:**
   Create a `.env` file from the example:
   ```env
   PORT=3000
   DATABASE_URL="postgresql://user:password@localhost:5432/spacerentals?schema=public"
   JWT_SECRET="supersecret_key_change_me_in_production"
   REDIS_URL="redis://localhost:6379"
   FAPSHI_API_URL="https://live.fapshi.com"
   FAPSHI_API_USER="your-fapshi-user"
   FAPSHI_API_KEY="your-fapshi-key"
   ```

3. **Database Setup:**
   Run Prisma migrations to prepare your Postgres database:
   ```bash
   npx prisma db push
   npx prisma generate
   ```

4. **Start the Development Server:**
   ```bash
   npm run dev
   ```
   *The server will run with `tsx watch` for hot-reloading.*

## API Endpoints

The API base URL is `http://localhost:3000/api`.

### Key Services:
- `POST /api/auth/register` - Create new landlord, tenant, or agent.
- `POST /api/auth/login` - Authenticate and retrieve JWT token.
- `GET /api/properties` - List properties (with optional `?q=Location` filter).
- `POST /api/applications` - Tenant applies for a property.
- `PATCH /api/applications/:id/approve` - Landlord approves application.
- `GET /api/agents/wallet` - Agents view their pending & available commissions.
- `GET /api/subscriptions/plans` - View platform subscription tiers for landlords.

## Deployment to External Device
If you are moving the project to run on an external device (e.g., testing locally on a phone in Cameroon):

1. **Find your local IP address** (e.g., `192.168.x.x`).
2. Run the backend using `npm run dev` as usual.
3. On the **Flutter frontend**, update the `API_BASE_URL` in `lib/config/api_config.dart` or your provider to point to `http://192.168.x.x:3000/api`.
4. Ensure your phone/device is on the **same WiFi network**.
