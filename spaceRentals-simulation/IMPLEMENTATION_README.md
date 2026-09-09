# SpaceRentals Implementation Guide

This document describes the implementation currently present in the SpaceRentals repository. It covers the Flutter application, the Node.js API, the PostgreSQL database managed by Prisma, authenticated storage, payment integrations, role permissions, and the workflows connecting tenants, landlords, agents, and administrators.

The platform follows one governing rule:

> Flutter requests an operation. The backend validates authorization and business rules. Prisma persists the result. External providers confirm payments or storage operations where required.

## 1. System Architecture

### Frontend

- Framework: Flutter
- State management: Riverpod
- Routing: GoRouter
- API access: repository classes through the shared `ApiClient`
- Session storage: `flutter_secure_storage` for JWT tokens and `SharedPreferences` for non-sensitive session metadata
- File selection: `image_picker`
- Localized interface: locale provider with English and French support

The frontend is located in `Frontend/`.

### Backend

- Runtime: Node.js
- Framework: Express 5
- Language: TypeScript
- ORM: Prisma
- Database: PostgreSQL
- Cache: Redis, with database fallback when Redis is unavailable
- Authentication: JWT and bcrypt
- Storage: Supabase Storage through the backend storage API
- Payments: Fapshi payment and webhook services
- Realtime: Socket.IO for messages and notifications
- Security: Helmet, CORS, rate limiting, role middleware, object-level authorization, encrypted KYC files, and audit logs

The backend is located in `Backend/`.

### Request lifecycle

1. Flutter calls a repository method.
2. The repository calls an API endpoint through `ApiClient`.
3. Authentication middleware validates the bearer token.
4. Role and verification middleware enforce access requirements.
5. Controllers validate input and delegate to services.
6. Services enforce ownership and state transitions.
7. Prisma reads or writes PostgreSQL records.
8. The API returns a typed response to Flutter.
9. Riverpod invalidates affected providers after mutations.

## 2. Authentication, Terms, and Sessions

### Registration

Endpoint: `POST /api/auth/register`

Supported roles:

- `tenant`
- `landlord`
- `agent`

Administrators are created through the protected admin user-management flow rather than public registration.

Registration requires acceptance of the current terms version. The backend stores:

- `User.termsAcceptedAt`
- `User.termsVersion`

The current terms version is defined by `CURRENT_TERMS_VERSION` in `Backend/src/services/AuthService.ts`.

Landlords are created with `pending_verification` account status. Agents receive an unapproved KYC state until they submit documents and are approved by an administrator.

### Login

Endpoint: `POST /api/auth/login`

The backend checks:

- Credentials
- Suspended account status
- Current terms version
- Password hash
- Landlord or agent verification state

The response includes the JWT and KYC metadata used by Flutter routing:

- `isKycVerified`
- `kycStatus`
- `termsAccepted`
- `termsVersion`

### Terms gateway

The Flutter terms screen is shown before authentication pages when the current terms have not been accepted locally. Acceptance is persisted locally and, for authenticated users, through:

`POST /api/auth/terms/accept`

The router directs users through `/terms`, `/login`, and `/register` without allowing an accepted user to become trapped on the terms page.

### Session refresh

Endpoint: `GET /api/auth/me`

The frontend refreshes the session to obtain current server-side KYC and terms state. This is important after an administrator approves or rejects a landlord or agent.

## 3. Tenant Workflow

### Tenant onboarding

1. User opens the application.
2. The terms gateway checks local acceptance.
3. The user accepts the current terms.
4. The user registers or signs in as a tenant.
5. Flutter stores the authenticated session.
6. The router sends the user to the tenant dashboard.

### Property discovery

Public property endpoints include:

- `GET /api/properties`
- `GET /api/properties/search`
- `GET /api/properties/nearby`
- `GET /api/properties/feed/video`
- `GET /api/properties/:id`
- `GET /api/properties/:id/comments`

Marketplace records are read from PostgreSQL. Search supports text, category, rent range, bedrooms, and optional geospatial filtering through H3 indexes.

### Property engagement

Authenticated tenants can:

- Comment on properties
- Like properties
- Reshare properties
- View property details
- Save or browse recently viewed properties in the Flutter experience

### Rental applications

Endpoint group: `/api/applications`

Tenant operations include:

- `POST /api/applications`
- `GET /api/applications/tenant`
- `GET /api/applications/:id`
- `PATCH /api/applications/:id/withdraw`

An application is persisted in the `Application` table with links to:

- Property
- Tenant
- Submitted identity document
- Proof of income
- Cover letter
- Status and landlord note

The application status lifecycle is:

`draft` -> `submitted` -> `under_review` -> `approved` or `rejected`

A tenant may also withdraw an eligible application. Duplicate application checks are enforced by the backend service.

### Lease signing

Endpoint group: `/api/leases`

Tenant lease operations include:

- `GET /api/leases/tenant`
- `GET /api/leases/:id`
- `GET /api/leases/by-application/:applicationId`
- `PATCH /api/leases/:id/sign`

The lease is generated from an approved application. Signatures are represented by hashes and timestamps, with IP metadata stored for the signing event. Lease status tracks generation, pending signatures, partial signing, signing completion, and activation.

### Payments and rent

Tenant payment operations use `/api/payments` and the Fapshi service. Payment records are stored in PostgreSQL and webhook callbacks update their state.

Payment statuses include:

- `created`
- `pending`
- `processing`
- `successful`
- `failed`

The `Payment` model also supports optional rent-period fields:

- `dueDate`
- `periodStart`
- `periodEnd`
- `paidAt`

### Tenant wallet and RNLP

Tenant wallet endpoints:

- `GET /api/tenant-wallet`
- `POST /api/tenant-wallet/apply-to-rent`
- `POST /api/tenant-wallet/withdraw`

RNLP endpoints support viewing a tenant's contract and paying instalments:

- `GET /api/rnlp/me`
- `POST /api/rnlp/instalments/:instalmentId/pay`

Wallet balances, wallet entries, withdrawals, RNLP contracts, and instalments are persisted in Prisma models.

### Maintenance, messages, notifications, and reviews

Tenant-facing operations include:

- Maintenance request creation and tracking
- Message conversations with landlords or other permitted users
- Read/unread message state
- Notification listing and read operations
- Property and landlord reviews
- Dispute creation for rental issues

The relevant database records are `MaintenanceRequest`, `Message`, `Notification`, `Review`, and `Dispute`.

## 4. Landlord Workflow

### Landlord onboarding and verification

A landlord cannot use landlord operational APIs until verification is approved.

Landlord KYC endpoints:

- `POST /api/landlord-verification`
- `GET /api/landlord-verification/me`
- `GET /api/landlord-verification` for administrators
- `PATCH /api/landlord-verification/:id/approve`
- `PATCH /api/landlord-verification/:id/reject`

The `LandlordVerification` record stores:

- Landlord ID
- Verification tier
- Status
- Document references
- Administrator notes
- Submission and update timestamps

The backend validates that submitted KYC file references exist in the private storage bucket.

The Flutter routing states are:

- `not_submitted` -> `/landlord/kyc`
- `pending` -> `/landlord/pending`
- `rejected` -> `/landlord/kyc`
- `approved` -> `/landlord`

### Verified landlord gate

The `requireVerifiedLandlord` middleware protects landlord operational endpoints. It checks the current `LandlordVerification.status` in PostgreSQL rather than trusting a client-side flag.

Protected operations include:

- Landlord dashboard
- Property creation and editing
- Property publishing and unpublishing
- Availability confirmation
- Property deletion
- Property boosting
- Landlord application review
- Landlord lease listing
- Landlord rental listing and rental ending
- Landlord payments and transactions
- Subscription operations
- Platform fee operations

Administrators can pass the gate for administrative operations.

### Landlord dashboard

Endpoint: `GET /api/dashboard/landlord`

The dashboard response is the server-authoritative snapshot used by the Flutter overview. It includes:

- Total properties
- Property counts by status
- Active listings
- Rented properties
- Total and pending applications
- Active rentals
- Occupied properties
- Rentable properties
- Occupancy percentage
- Expected monthly rent
- Collected amount this month
- Pending payment amount
- Open maintenance count
- Unread message count
- Recent activity
- Six-month successful rent collection history

Occupancy uses available, reserved, and rented properties as the rentable denominator. Draft and unpublished properties are excluded from the denominator.

Dashboard values are cached in Redis for five minutes when Redis is available. The frontend has retry and refresh behavior.

### Rent analytics

The dashboard returns monthly collection points for the current month and the previous five months. Successful payments are grouped by successful payment creation month.

The Flutter landlord dashboard displays:

- Expected monthly rent
- Occupancy percentage
- Outstanding payment amount
- Open maintenance count
- Unread messages
- Six-month rent collection chart
- Recent backend-generated activity

The current historical grouping is payment-timestamp based. The optional rent-period fields provide the foundation for strict due-period accounting and overdue reports.

### Property management

Property endpoints:

- `GET /api/properties/my/listings`
- `POST /api/properties`
- `PATCH /api/properties/:id`
- `DELETE /api/properties/:id`
- `PATCH /api/properties/:id/publish`
- `PATCH /api/properties/:id/unpublish`
- `PATCH /api/properties/:id/confirm-availability`
- `POST /api/properties/:id/boost`

Property records are stored in the `Property` model and include:

- Title and description
- Location and coordinates
- Rent and deposit
- Bedrooms and bathrooms
- Area
- Images and videos
- Amenities
- Furnishing
- Parking
- Water and electricity availability
- Fencing and road access
- Security information
- Category
- Acquisition source and agent attribution
- Availability timestamps

The Flutter property edit screen is backed by `PATCH /api/properties/:id` and persists the editable fields through `ApiPropertyRepository`.

Backend property update validation checks:

- Positive monthly rent
- Non-negative deposit
- Valid bedroom, bathroom, area, and parking values
- Valid latitude and longitude ranges
- Allowed property status values
- Non-empty update payload
- Ownership or administrator authorization

Properties with active rentals cannot be deleted.

### Application, lease, rental, and payment management

Verified landlords can:

- View applications for their properties
- Approve or reject applications with notes
- Access lease workflows
- View landlord rentals
- End eligible rentals
- View landlord payment transactions
- Initiate permitted payment operations
- Pay platform fees
- View and initiate subscriptions
- View maintenance requests
- Communicate with tenants

Ownership checks are performed in backend services before resource mutation or retrieval.

### Agent marketplace and agreements

The landlord agent marketplace lists verified, active agents from the backend agent endpoint.

The landlord can request an agent service through:

`POST /api/agent-agreements`

The request is persisted in `AgentServiceAgreement` with:

- Landlord
- Agent
- Service terms
- Status
- Request timestamp
- Acceptance timestamp

The backend only permits requests to agents whose KYC status is `approved`.

Agreement listing endpoint:

`GET /api/agent-agreements`

Agent decision endpoint:

`PATCH /api/agent-agreements/:id/decision`

The agent can accept or terminate a pending agreement. Requests and decisions are audit logged.

## 5. Agent Workflow

### Agent registration and KYC

Agent KYC endpoints:

- `GET /api/agents/kyc/me`
- `POST /api/agents/kyc`
- `GET /api/agents/kyc` for administrators
- `GET /api/agents/kyc/pending` for administrators
- `PATCH /api/agents/kyc/:id/approve`
- `PATCH /api/agents/kyc/:id/reject`

The Flutter agent KYC screen uploads documents through the authenticated storage API and submits their stored paths to the backend.

The backend requires:

- A national ID document
- Valid document path ownership under the agent's user folder
- Document existence in the `kyc-documents` bucket

Optional documents include:

- Selfie
- Agency or business document
- Tax card

The `AgentVerification` model stores document JSON, individual document references, status, administrator notes, and submission timestamps.

### Administrator decisions and agent status

When an administrator approves agent KYC:

- Verification status becomes `approved`
- Agent user status becomes `active`
- Audit log entry is created

When an administrator rejects agent KYC:

- Verification status becomes `rejected`
- Agent user status becomes `kyc_rejected`
- Administrator notes are stored
- Audit log entry is created

When an agent resubmits:

- The verification row returns to `pending`
- The agent user status returns to `pending_verification`

The agent pending screen refreshes `/api/auth/me` and reacts to both approval and rejection.

### Agent approval gate

The `requireVerifiedAgent` middleware protects operational agent functions while allowing an unapproved agent to submit and check KYC.

Protected functions include:

- Agent wallet access
- Withdrawal requests
- Withdrawal history
- Commission history
- Landlord-agent agreement decisions

The public marketplace only returns the verification flag for agent discovery, while the backend controls whether an agent can perform protected operations.

### Agent commissions and withdrawals

Agent ledger records are stored in `AgentTransaction`.

Supported concepts include:

- Pending commissions
- Eligible commissions
- Available commissions
- Withdrawal processing
- Paid withdrawals
- Failed withdrawals

Withdrawal requests validate amount, payment method, available balance, agent role, and approved KYC. Idempotency keys protect ledger operations from duplicate processing.

Commission webhook processing requires an HMAC signature and updates both withdrawal and reserved commission records.

### Landlord-agent property attribution

Properties support:

- `acquisitionSource`
- `acquisitionAgentId`

These fields allow the platform to attribute property acquisition and future commission events to an agent. The backend service controls property ownership and mutation authorization.

## 6. Administrator Workflow

### Administrator access

All `/api/admin/*` routes require:

1. A valid JWT
2. The `admin` role

Administrative actions are also rate limited.

### Admin dashboard

The admin overview aggregates:

- Users by role and status
- Suspended users
- Pending agent KYC
- Open and under-review disputes
- Properties by status
- Applications by status
- Leases by status
- Rentals by status
- Successful revenue
- Pending payments
- Open maintenance requests
- Active subscriptions

Endpoints include:

- `GET /api/admin/overview`
- `GET /api/admin/reports/summary`
- `GET /api/admin/transactions`
- `GET /api/admin/properties`
- `GET /api/admin/platform-fees`
- `GET /api/admin/subscriptions`

### User administration

Administrators can:

- List users
- Create administrators
- Suspend users
- Activate users
- Bulk suspend users
- View user profiles

Suspension and activation are persisted to `User.status` and recorded in the audit log.

### Agent KYC review

The Flutter admin KYC management screen loads real records from:

`GET /api/agents/kyc`

For every submission, administrators can:

- See agent identity and contact information
- See submission status
- See all stored document references
- Open documents inside the application
- Approve pending KYC
- Reject pending KYC
- Refresh the review list

Document viewing uses:

`GET /api/storage/download?bucket=kyc-documents&path=...`

The backend checks administrator authorization, downloads the encrypted file, decrypts it server-side, and returns the document bytes. KYC uploads are restricted to image formats supported by the review UI.

### Landlord KYC review

The landlord admin review screen follows the same storage and decision pattern through `/api/landlord-verification`.

Administrators can review basic or premium landlord verification submissions, open documents, approve, reject, and record administrator notes.

### Disputes and operations

Administrator operations include:

- List disputes
- View a dispute
- Move a dispute into review
- Resolve a dispute
- Monitor maintenance and platform operations

Dispute state is stored in `Dispute`, and rental status changes associated with dispute resolution are persisted by the backend service.

### Financial oversight

Administrators can inspect:

- Payment transactions
- Platform fees
- Subscriptions
- Agent commissions
- Agent withdrawal ledger records
- Successful revenue
- Audit entries

Payment provider webhooks update database state; administrator screens read the stored state rather than local mock data.

## 7. Database Model Overview

The Prisma schema contains the following major records:

### Identity and governance

- `User`
- `AuditLog`
- `PasswordResetToken`
- `Notification`

### Verification

- `AgentVerification`
- `LandlordVerification`
- `AgentServiceAgreement`

### Property and rental lifecycle

- `Property`
- `PropertyVerification`
- `Application`
- `Lease`
- `Rental`
- `MaintenanceRequest`
- `Review`
- `Dispute`

### Financial records

- `Payment`
- `Transaction`
- `PlatformFee`
- `Subscription`
- `AgentTransaction`
- `TenantWallet`
- `TenantWalletEntry`
- `TenantWithdrawal`
- `RnlpContract`
- `RnlpInstalment`

### Communication and engagement

- `Message`
- `Comment`
- `PropertyLike`
- `PropertyReshare`
- `Follow`

Relations connect tenant applications to properties, approved applications to leases, leases to rentals and payments, rentals to maintenance and disputes, and users to role-specific verification and financial records.

## 8. Storage and Document Security

All storage requests are authenticated through `/api/storage`.

Supported buckets include:

- `property-images`
- `kyc-documents`
- `lease-documents`
- `profile-images`

KYC behavior:

1. Flutter uploads through the backend, not directly with unrestricted storage credentials.
2. The backend generates a user-scoped path.
3. KYC files are encrypted before storage.
4. Document references are validated during KYC submission.
5. Administrators download documents through an authenticated endpoint.
6. The backend decrypts KYC files only while serving an authorized download.
7. Signed URLs and downloads reject paths belonging to another user unless the caller is an administrator.

Failed KYC uploads can be cleaned up through the protected orphan cleanup route. Referenced documents are never deleted by that operation.

## 9. Authorization Rules

The API uses multiple authorization layers:

- `authenticate`: validates JWT and current user status
- `requireRole`: enforces role membership
- `requireAdmin`: administrator-only operations
- `requireLandlord`: landlord or administrator role
- `requireAgent`: agent or administrator role
- `requireVerifiedLandlord`: approved landlord verification required
- `requireVerifiedAgent`: approved agent verification required
- Ownership checks inside services and controllers
- Resource-level checks for applications, properties, leases, rentals, payments, files, and agreements

Frontend route guards improve navigation but are not security boundaries. Backend middleware and service checks are authoritative.

## 10. Caching and State Synchronization

Redis is optional. When available, it caches:

- Dashboard snapshots
- Marketplace property reads
- Property detail reads
- Property searches
- Rate-limit counters where configured

The backend clears relevant property and landlord dashboard cache entries after property creation, update, deletion, publishing, unpublishing, and availability confirmation.

Flutter invalidates Riverpod providers after successful mutations, including:

- Property changes
- Application decisions
- KYC decisions
- Agent agreement requests
- Dashboard refreshes

## 11. Running the System

### Backend prerequisites

- Node.js 22 or later
- PostgreSQL 15 or later
- Redis, optional
- Supabase storage configuration
- Fapshi configuration for payment operations

### Backend setup

```bash
cd Backend
npm install
npx prisma generate
npx prisma db push --accept-data-loss=false
npm run dev
```

The API listens on port `3000` by default.

### Frontend setup

```bash
cd Frontend
flutter pub get
flutter run
```

Configure the frontend API base URL through the Flutter environment configuration used by `ApiEndpoints`.

For Android device testing against a backend running on the development machine:

```bash
adb reverse tcp:3000 tcp:3000
```

The workspace path contains spaces. Flutter commands may need to be executed from a quoted path or from a temporary copied directory on some Linux toolchain versions.

## 12. Validation Performed

The implemented workflows have been checked with:

- Prisma client generation
- Prisma database synchronization
- Backend TypeScript compilation through `npm run build`
- Flutter analyzer on affected dashboard, property, agent, and contract files
- Flutter widget tests through `flutter test test/widget_test.dart`
- Backend health endpoint checks during device testing

The current focused widget test passes. Flutter analyzer output may still contain style-level informational lints in older files; touched contract files have no blocking diagnostics.

## 13. Current Accounting Boundary

The dashboard's historical collection chart groups successful payments by payment creation month. This is useful for collection reporting, but it is not yet a complete rent-period ledger.

For strict rent accounting, payment creation and rent obligation should be separated by populating:

- `Payment.dueDate`
- `Payment.periodStart`
- `Payment.periodEnd`
- `Payment.paidAt`

A future rent ledger can then calculate overdue rent, partial payments, collection rate, payment aging, and period-based landlord statements without inferring obligations from payment timestamps.

## 14. Source Locations

### Backend

- `Backend/src/index.ts` - application and route registration
- `Backend/src/routes/` - API route contracts
- `Backend/src/controllers/` - HTTP boundary handlers
- `Backend/src/services/` - business rules and persistence orchestration
- `Backend/src/middleware/authMiddleware.ts` - authentication and role gates
- `Backend/src/services/SupabaseService.ts` - storage operations
- `Backend/src/services/AuditLogService.ts` - audit persistence
- `Backend/prisma/schema.prisma` - database contract

### Frontend

- `Frontend/lib/app/routes.dart` - route guards and navigation
- `Frontend/lib/providers/` - Riverpod state providers
- `Frontend/lib/data/api/` - backend repositories
- `Frontend/lib/features/auth/` - terms, registration, login, and sessions
- `Frontend/lib/features/tenant/` - tenant workflow
- `Frontend/lib/features/landlord/` - landlord workflow and dashboard
- `Frontend/lib/features/agent/` - agent workflow and KYC
- `Frontend/lib/features/admin/` - administrator workflow and review tools
- `Frontend/lib/core/api/` - API client, endpoints, and storage client
