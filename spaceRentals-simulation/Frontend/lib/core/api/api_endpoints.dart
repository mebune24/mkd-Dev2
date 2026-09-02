import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API endpoint definitions.
/// All backend URLs are loaded from .env — never hardcoded.
class ApiEndpoints {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:3000';
  static String get _base => '$baseUrl/api';

  // Auth
  static String get signIn => '$_base/auth/login';
  static String get signUp => '$_base/auth/register';
  static String get signOut => '$_base/auth/signout';
  static String get refreshToken => '$_base/auth/refresh';
  static String get me => '$_base/auth/me';
  static String get passwordReset => '$_base/auth/password-reset';
  static String get passwordResetConfirm => '$_base/auth/password-reset/confirm';
  static String get changePassword => '$_base/auth/change-password';

  // User Profile
  static String get userProfile => '$_base/users/profile';

  // Properties
  static String get properties => '$_base/properties';
  static String property(String id) => '$_base/properties/$id';
  static String propertyVerification(String id) => '$_base/properties/$id/verification';
  static String confirmAvailability(String id) => '$_base/properties/$id/confirm-availability';

  // Applications
  static String get applications => '$_base/applications';
  static String application(String id) => '$_base/applications/$id';
  static String approveApplication(String id) => '$_base/applications/$id/approve';
  static String rejectApplication(String id) => '$_base/applications/$id/reject';
  static String withdrawApplication(String id) => '$_base/applications/$id/withdraw';

  // Leases
  static String get leases => '$_base/leases';
  static String lease(String id) => '$_base/leases/$id';
  static String signLease(String id) => '$_base/leases/$id/sign';

  // Rentals
  static String get rentals => '$_base/rentals';
  static String rental(String id) => '$_base/rentals/$id';

  // Platform Fees
  static String get platformFees => '$_base/platform-fees';
  static String platformFee(String id) => '$_base/platform-fees/$id';
  static String initiateFeePayment(String id) => '$_base/platform-fees/$id/pay';
  static String waiveFee(String id) => '$_base/platform-fees/$id/waive';

  // Payments
  static String get payments => '$_base/payments';
  static String payment(String id) => '$_base/payments/$id';
  static String paymentStatus(String id) => '$_base/payments/$id/status';

  // Subscriptions
  static String get subscriptions => '$_base/subscriptions';
  static String get subscriptionPlans => '$_base/subscriptions/plans';
  static String get mySubscription => '$_base/subscriptions/me';

  // Agents
  static String get agentApplications => '$_base/agent-applications';
  static String get myAgentApplication => '$_base/agent-applications/me';
  static String agentApplication(String id) => '$_base/agent-applications/$id';
  static String approveAgent(String id) => '$_base/agent-applications/$id/approve';
  static String rejectAgent(String id) => '$_base/agent-applications/$id/reject';

  // Commissions
  static String get commissions => '$_base/commissions';
  static String commission(String id) => '$_base/commissions/$id';

  // Wallet & Withdrawals
  static String get wallet => '$_base/wallet';
  static String get withdrawals => '$_base/wallet/withdrawals';
  static String withdrawal(String id) => '$_base/wallet/withdrawals/$id';
  static String freezeWallet(String agentId) => '$_base/admin/agents/$agentId/wallet/freeze';
  static String unfreezeWallet(String agentId) => '$_base/admin/agents/$agentId/wallet/unfreeze';

  // Admin
  static String get adminUsers => '$_base/admin/users';
  static String adminUser(String id) => '$_base/admin/users/$id';
  static String get adminProperties => '$_base/admin/properties';
  static String get adminAgents => '$_base/admin/agents';
}
