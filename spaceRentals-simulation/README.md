# Space Rentals 🏠

Space Rentals is a comprehensive property rental platform connecting **Tenants**, **Landlords**, **Field Agents**, and **Administrators** in Cameroon (and beyond). It features a Flutter-based cross-platform mobile application and a Node.js/Express backend API.

---

## 🎯 Architecture

The platform is split into two primary components:

1. **`space_rentals/` (Frontend):** A rich, cross-platform Flutter application leveraging Riverpod for state management, providing distinct dashboards for the 4 user roles.
2. **`Backend/` (API):** A Node.js and Express RESTful API utilizing Prisma ORM and SQLite (easily migratable to PostgreSQL) to handle real data persistence, JWT authentication, and business logic.

---

## 🚀 Features by Role

### 👥 Tenants
- Browse and search available verified properties.
- Submit rental applications directly through the app.
- Monetize via the **Refer & Earn** program (invite landlords/tenants).
- Participate in **Micro-Gigs** (e.g., helping landlords clean or inspect properties).

### 🏢 Landlords
- List and manage rental properties.
- Review and approve/reject tenant applications.
- Hire verified Field Agents to represent them, show properties, and handle acquisitions.
- Post Micro-Gigs for tenants to complete.

### 🕵️ Field Agents
- Perform KYC (Know Your Customer) and property verifications.
- Handle property acquisitions and earn commissions (e.g., 2,000 FCFA per property).
- Earn referral commissions (e.g., 1,000 FCFA per tenant referral).
- Track mobile money withdrawals directly from the Agent Dashboard.

### 🛡️ Administrators
- Approve or reject Agent/Landlord/Tenant KYC submissions.
- Resolve disputes between users.
- Verify properties for "Level 3 Verified" status.
- Monitor global transactions and user statistics.

---

## 💻 Tech Stack

### Frontend (Flutter)
*   **Framework:** Flutter (Dart)
*   **State Management:** Riverpod
*   **Routing:** GoRouter
*   **UI/UX Architecture:** Unified `FormSafeModal` (prevents data loss) and central Toast Notifications system.

### Backend (Node.js)
*   **Framework:** Express.js (TypeScript)
*   **ORM:** Prisma
*   **Database:** SQLite (development) -> PostgreSQL (production ready)
*   **Security:** JWT (JSON Web Tokens), bcrypt (Password Hashing)

---

## 🛠️ Getting Started

### 1. Running the Node.js Backend

1. Navigate to the backend directory:
   ```bash
   cd Backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up your environment variables by checking the `.env` file (already preconfigured for local dev).
4. Run Prisma database migrations to create the SQLite database:
   ```bash
   npx prisma db push
   ```
5. Start the development server (runs on port 3000):
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

## 💰 Unit Economics & Business Model (Example)

Space Rentals generates revenue through platform fees rather than taking a percentage of the actual rent. For example, on a **45,000 FCFA** monthly rent:

*   **100% of the Rent (45k)** goes directly to the Landlord.
*   **Platform Subscription:** 5,000 FCFA / month (paid by Landlord).
*   **Tenant Application Fee:** 3,000 FCFA (paid by Tenant via Mobile Money integration).
*   **Success Fee:** 10,000 FCFA upon successful lease signing.
*   **Agent Commissions:** Paid out from the platform's Success/Application fees (e.g., 1k for tenant referral, 2k for property acquisition).

*(Note: These figures are variables and subject to final business rules, but represent the operational logic of the platform).*

---

## 🤝 Contribution Guidelines

- When modifying forms in the Flutter app, ensure they are wrapped in `FormSafeModal` to prevent accidental loss of user data.
- Ensure all passive notifications use `context.showToast()`, `context.showSuccessToast()`, or `context.showErrorToast()` from `lib/core/utils/ui_helpers.dart` rather than raw `ScaffoldMessenger` calls.
