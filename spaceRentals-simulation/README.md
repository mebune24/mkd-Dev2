# Space Rentals 🏠

Space Rentals is a comprehensive **property rental platform** connecting **Tenants**, **Landlords**, **Field Agents**, and **Administrators** in Cameroon (and beyond). It features a Flutter-based cross-platform mobile application and a Node.js/Express backend API.

---

## 🎯 Architecture

The platform is split into two primary components:

1. **`space_rentals/` (Frontend):** A rich, cross-platform Flutter application leveraging Riverpod for state management, providing distinct dashboards for the 4 user roles.
2. **`Backend/` (API):** A Node.js and Express RESTful API utilizing Prisma ORM and PostgreSQL to handle real data persistence, JWT authentication, object-level authorization, and strict domain state machines.

> **Note on Architecture Principle:**
> The Flutter app requests actions; the backend decides whether those actions are valid; the database records the resulting state; and payment providers confirm financial events.

---

## 🚀 Features by Role (MVP)

### 👥 Tenants
- **Register & Verify:** Basic identity verification.
- **Browse & Search:** Find available, verified properties.
- **Apply & Track:** Submit rental applications and track their progress through the state machine.
- **Lease & Rent:** Sign leases and enter active rentals.

### 🏢 Landlords
- **Register & Verify:** Identity and ownership authority verification.
- **Subscribe:** Pay the monthly platform subscription.
- **List Properties:** Create property listings and get them verified by Field Agents.
- **Manage Applications:** Receive, review, and approve tenant applications.
- **Lease & Rent:** Sign leases and collect rent directly from tenants.
- **Platform Fees:** Pay the Space success fee once a rental becomes active.

### 🕵️ Field Agents
- **Register & Verify:** Full KYC verification and Admin approval.
- **Property Acquisition:** Submit properties on behalf of landlords.
- **Property Verification:** Perform on-the-ground physical verifications.
- **Earn Commissions:** Track attributed properties and earn commissions (e.g., 2,000 FCFA) per **successfully rented** property acquired by the agent.
- **Withdrawals:** Withdraw eligible commissions via Mobile Money.

### 🛡️ Administrators
- **KYC & Verification:** Review and approve different tiers of user verification.
- **Dispute Resolution:** Handle disputes between landlords and tenants.
- **Financial Oversight:** Monitor payments, subscriptions, commissions, and agent wallets via the immutable ledger.
- **Audit Logs:** Review systemic actions.

---

## 💻 Tech Stack

### Frontend (Flutter)
*   **Framework:** Flutter (Dart)
*   **State Management:** Riverpod
*   **Routing:** GoRouter
*   **Architecture:** Repository Pattern, Use Case Pattern, Dependency Injection.
*   **UI/UX:** Unified `FormSafeModal` (prevents data loss) and central Toast Notifications system.

### Backend (Node.js)
*   **Framework:** Express.js (TypeScript)
*   **ORM:** Prisma
*   **Database:** PostgreSQL (Docker for dev, Managed for prod)
*   **Security:** JWT (JSON Web Tokens), bcrypt (Password Hashing), Object-Level Authorization (RBAC).
*   **Financials:** Idempotent payment webhooks and a strict AgentTransaction ledger.

---

## 🛠️ Getting Started

### 1. Running the Node.js Backend

1. Navigate to the backend directory:
   ```bash
   cd Backend
   ```
2. Start the PostgreSQL Docker container (Ensure Docker is running):
   ```bash
   docker-compose up -d
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Set up your environment variables by checking the `.env` file.
5. Run Prisma database migrations to create the PostgreSQL schema:
   ```bash
   npx prisma migrate dev
   ```
6. Start the development server:
   ```bash
   npm run dev
   # OR using tsx directly:
   npx tsx src/index.ts
   ```

### 2. Running the Flutter App

1. Navigate to the flutter app directory:
   ```bash
   cd space_rentals
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 💰 Unit Economics & Business Model

Space Rentals generates revenue through platform fees rather than taking a percentage of the actual rent. 

> **Important:** Space does **NOT** escrow the monthly rent. 100% of the rent goes directly from the Tenant to the Landlord.

For example, on a **45,000 FCFA** monthly rent:

*   **Tenant Application Fee:** 3,000 FCFA (paid by Tenant via Mobile Money).
*   **Platform Subscription:** 5,000 FCFA / month (paid by Landlord).
*   **Success/Platform Fee:** 10,000 FCFA (paid by Landlord) due **only when the rental becomes active** after the initial rent/deposit payment is confirmed.

**Agent Commissions:** 
Commissions (e.g., 2,000 FCFA for property acquisition) become eligible for payout **only after** the property gets rented and the initial payment is confirmed.

---

## 🤝 Core Domain State Machines

The backend enforces strict state transitions. Examples include:

- **Application:** `DRAFT` → `SUBMITTED` → `UNDER_REVIEW` → (`APPROVED` | `REJECTED` | `WITHDRAWN`)
- **Lease:** `GENERATED` → `PENDING_TENANT_SIGNATURE` → `PENDING_LANDLORD_SIGNATURE` → `SIGNED`
- **Payment:** `CREATED` → `PENDING` → `PROCESSING` → (`SUCCESSFUL` | `FAILED` | `EXPIRED`)
- **Platform Fee:** `NOT_DUE` → `DUE` → `PAYMENT_PROCESSING` → `PAID`
- **Agent Commission:** `PENDING` → `ELIGIBLE` → `AVAILABLE` → `WITHDRAWAL_REQUESTED` → `PROCESSING` → (`PAID` | `FAILED`)
