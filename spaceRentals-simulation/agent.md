# Agent Functionality & Workflow

In SpaceRentals, **Agents** play a crucial role as the intermediary trust layer between landlords and tenants. They act as independent contractors who bring supply (properties) and demand (tenants) to the platform in exchange for commissions.

---

## 1. Overall Function in the System

### Onboarding & KYC
- **Registration**: Agents register on the platform via the Agent onboarding flow.
- **Verification**: Agents must submit KYC documents (National ID, Selfie, Business Docs). The backend (`KycVerificationService`) automatically scores and approves/rejects these documents. Only approved agents receive the "Verified" badge and appear in the public Agent Marketplace.

### The Agent Marketplace
- Landlords seeking help managing their properties or finding tenants can browse the **Agent Marketplace**.
- Landlords can view agent profiles, their ratings, locations, and previous successful rentals, and send a **Service Agreement Request** to hire them.

### Core Activities
1. **Property Verification (Supply side)**:
   - Agents visit properties in person, take high-quality photos, verify amenities, and ensure the landlord actually owns the property.
   - Upon successful verification, the property receives a "Verified" badge, boosting its visibility in the tenant search feed.
2. **Tenant Referral (Demand side)**:
   - Agents guide tenants through the app, helping them find suitable properties and submit applications.
   - If an application is successful and the tenant signs the digital lease, the agent is credited as the referrer.

### Commissions & Payouts
- **Earning**: Agents earn commissions for every property verified and every successful tenant referred. These commissions accumulate in their in-app Wallet.
- **Withdrawal**: Agents can request to withdraw their available balance. The platform initiates a payout via the **Fapshi Payment Gateway**, sending the money directly to the agent's MTN Mobile Money or Orange Money account.

---

## 2. Lacking (Beneficial but Non-Detrimental)

While the core pipeline for agents (KYC, Verification, Wallet) is structurally sound, the following features are lacking for a *full* implementation. These are not detrimental to the current MVP but would be highly beneficial for scaling:

1. **Automated Fapshi Payout API Integration**
   - *Current State*: The `initiatePayout` method in the backend simulates a successful payout after 5 seconds to demonstrate the flow.
   - *Improvement*: Integrating the actual Fapshi Disbursement API so that when an agent clicks "Withdraw", the money instantly hits their Mobile Money wallet without manual admin approval.

2. **Geolocation-based Agent Routing**
   - *Current State*: Landlords just see a list of verified agents and pick one.
   - *Improvement*: Use GPS to auto-suggest the closest verified agent to a landlord's property. This reduces agent travel time and increases efficiency.

3. **In-App Agent-Landlord Chat**
   - *Current State*: The UI for chat exists, and the backend Socket.io server is implemented, but the frontend needs to be wired to the Socket server so agents and landlords can negotiate terms directly in the app rather than switching to WhatsApp.

4. **Agent Tiering System**
   - *Current State*: Agents have basic ratings.
   - *Improvement*: Implement an automated tier system (e.g., Bronze, Silver, Gold). Agents with high success rates and fast verification times get promoted to Gold, giving them higher commission percentages and priority ranking in the marketplace.

5. **Dispute Resolution Tracking**
   - *Current State*: Basic dispute flags exist.
   - *Improvement*: A dedicated workflow for when a landlord disputes an agent's verification (e.g., the agent claimed a property was good, but it was fraudulent). The platform needs a way to "Freeze" an agent's wallet while the admin investigates.
