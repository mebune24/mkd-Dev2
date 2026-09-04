# SpaceRentals Application Status & Overview

Welcome to the SpaceRentals project repository. This document outlines the current state of the application, including fully functional features, missing components, areas for reinforcement, and an analysis of current security risks.

---

## 🟢 1. Fully Functional Features

The core architecture of SpaceRentals is built on a robust Node.js/Express backend (using Prisma ORM & PostgreSQL) and a Flutter Riverpod frontend. The following systems are completely wired and functional:

### **Authentication & Authorization**
- **JWT-based Auth**: Secure login and registration with BCrypt password hashing.
- **Role-Based Access Control (RBAC)**: Distinct roles (`admin`, `landlord`, `tenant`, `agent`) with strict middleware enforcement.
- **Object-Level Access Control (OLAC)**: Middleware ensures users can only modify their own properties, applications, and leases.
- **Password Reset Flow**: Secure token generation, expiration tracking, and reset endpoints.

### **Property & Lease Management**
- **Property Lifecycle**: Landlords can create, update, and manage properties.
- **Application Flow**: Tenants can apply for properties, and landlords can approve/reject them.
- **Digital Leases**: End-to-end lease generation and electronic signing (SHA-256 hashed timestamps) compliant with local regulations.

### **Payments & Financials**
- **Fapshi Integration**: Real payment gateway integration for MTN and Orange Money.
- **Webhook Handling**: Automated transaction status updates via Fapshi webhooks.
- **Rentals Engine**: Tracks active rentals, deposits, and monthly rent schedules.

### **Admin & Agent Portals**
- **Admin Dashboard**: Real-time metrics, user management, and platform fee tracking.
- **Agent System**: Agent onboarding, property verification, and commission tracking.

### **Infrastructure**
- **Rate Limiting**: Strict per-route limiters (e.g., Auth: 20/15m, Payments: 30/15m, Admin: 60/15m) using `express-rate-limit`.
- **Background Workers**: Automated Cron jobs for expiring password tokens and auto-unpublishing stale properties.
- **Caching**: Redis middleware implementation for heavy read endpoints.

---

## 🟡 2. Lacking / Missing Features

While the core loop is functional, several secondary features are currently mocked or incomplete:

1. **In-App Messaging/Chat**: The frontend UI exists, but there is no real-time WebSocket backend (e.g., Socket.io) to support live chat between tenants and landlords.
2. **Push Notifications**: Notifications are currently stored in the database and polled. Firebase Cloud Messaging (FCM) needs to be integrated for real-time mobile push notifications.
3. **Automated Payouts**: While tenant payments *in* are handled via Fapshi, agent commissions and landlord withdrawals *out* require integration with Fapshi's Payout API.
4. **Third-Party KYC Verification**: KYC document uploads exist, but they are not yet piped into an automated identity verification API (e.g., SmileID or Dojah).
5. **Deep Linking**: The app does not yet support universal links (opening specific app screens directly from email links).

---

## 🔵 3. Areas to Reinforce

To ensure the application scales gracefully and maintains high performance, the following areas should be reinforced:

1. **Comprehensive Testing**: The codebase needs a robust suite of Unit Tests (Jest for backend, Flutter Test for frontend) and E2E Tests (Integration testing for critical payment flows).
2. **Database Optimization**: As the `Property`, `Rental`, and `Transaction` tables grow, composite indexes must be added to Prisma to speed up complex dashboard queries.
3. **Advanced Caching**: Expand Redis caching to include dashboard metrics and high-traffic search queries, implementing cache invalidation strategies on data mutation.
4. **Error Tracking & Observability**: Integrate tools like Sentry for real-time crash reporting and Datadog/NewRelic for backend performance monitoring.
5. **State Management Refinement**: Ensure all Riverpod providers efficiently cache and invalidate state to prevent unnecessary API calls on the frontend.

---

## 🔴 4. Current Security Risks

The application implements standard security practices (Helmet, CORS, rate limiting), but the following risks must be addressed before a large-scale public launch:

1. **Webhook Forgery**: 
   - *Risk*: Malicious actors could send fake success payloads to the `/api/payments/webhook` endpoint.
   - *Mitigation*: Ensure the webhook endpoint cryptographically verifies Fapshi's HMAC signature using the API secret.
2. **IP-Based Rate Limiting Bypass**:
   - *Risk*: `express-rate-limit` relies on IP addresses. Attackers using rotating proxies or VPNs can bypass these limits.
   - *Mitigation*: Implement User-ID based rate limiting for authenticated routes, especially for payments and admin actions.
3. **KYC Data Privacy (Data at Rest)**:
   - *Risk*: Sensitive ID cards and personal documents are uploaded to storage. If the storage bucket is compromised, PII is leaked.
   - *Mitigation*: Implement client-side encryption or strict KMS-managed server-side encryption for all KYC documents. Ensure bucket ACLs are strictly private.
4. **Email Spoofing (Password Resets)**:
   - *Risk*: Without strict DNS records, phishing emails pretending to be SpaceRentals password resets could be sent to users.
   - *Mitigation*: Ensure the production email domain has strict SPF, DKIM, and DMARC policies enforced.
5. **Idempotency Keys**:
   - *Risk*: Network timeouts during payment initiation could lead to double-charging a user if they retry.
   - *Mitigation*: Implement robust idempotency key checking in the `PaymentController` to safely handle duplicate requests.
