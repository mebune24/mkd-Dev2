/// Centralized API endpoint definitions.
/// All backend URLs live here — never scattered in repositories.
class ApiEndpoints {
  // Use 127.0.0.1 because adb reverse tcp:3000 tcp:3000 is running
  static const String baseUrl = 'http://127.0.0.1:3000';
  // Backend registers routes under /api (no version prefix)
  static const String _base = '$baseUrl/api';

  // Auth
  static const String signIn = '$_base/auth/login';
  static const String signUp = '$_base/auth/register';
  static const String signOut = '$_base/auth/signout';
  static const String refreshToken = '$_base/auth/refresh';
  static const String me = '$_base/auth/me';
  static const String passwordReset = '$_base/auth/password-reset';
  static const String changePassword = '$_base/auth/change-password';

  // User Profile
  static const String userProfile = '$_base/users/profile';

  // Properties
  static const String properties = '$_base/properties';
  static String property(String id) => '$_base/properties/$id';
  static String propertyVerification(String id) => '$_base/properties/$id/verification';
  static String confirmAvailability(String id) => '$_base/properties/$id/confirm-availability';

  // Applications
  static const String applications = '$_base/applications';
  static String application(String id) => '$_base/applications/$id';
  static String approveApplication(String id) => '$_base/applications/$id/approve';
  static String rejectApplication(String id) => '$_base/applications/$id/reject';
  static String withdrawApplication(String id) => '$_base/applications/$id/withdraw';

  // Leases
  static const String leases = '$_base/leases';
  static String lease(String id) => '$_base/leases/$id';
  static String signLease(String id) => '$_base/leases/$id/sign';

  // Rentals
  static const String rentals = '$_base/rentals';
  static String rental(String id) => '$_base/rentals/$id';

  // Platform Fees
  static const String platformFees = '$_base/platform-fees';
  static String platformFee(String id) => '$_base/platform-fees/$id';
  static String initiateFeePayment(String id) => '$_base/platform-fees/$id/pay';
  static String waiveFee(String id) => '$_base/platform-fees/$id/waive';

  // Payments
  static const String payments = '$_base/payments';
  static String payment(String id) => '$_base/payments/$id';
  static String paymentStatus(String id) => '$_base/payments/$id/status';

  // Subscriptions
  static const String subscriptions = '$_base/subscriptions';
  static const String subscriptionPlans = '$_base/subscriptions/plans';
  static const String mySubscription = '$_base/subscriptions/me';

  // Agents
  static const String agentApplications = '$_base/agent-applications';
  static const String myAgentApplication = '$_base/agent-applications/me';
  static String agentApplication(String id) => '$_base/agent-applications/$id';
  static String approveAgent(String id) => '$_base/agent-applications/$id/approve';
  static String rejectAgent(String id) => '$_base/agent-applications/$id/reject';

  // Commissions
  static const String commissions = '$_base/commissions';
  static String commission(String id) => '$_base/commissions/$id';

  // Wallet & Withdrawals
  static const String wallet = '$_base/wallet';
  static const String withdrawals = '$_base/wallet/withdrawals';
  static String withdrawal(String id) => '$_base/wallet/withdrawals/$id';
  static String freezeWallet(String agentId) => '$_base/admin/agents/$agentId/wallet/freeze';
  static String unfreezeWallet(String agentId) => '$_base/admin/agents/$agentId/wallet/unfreeze';

  // Admin
  static const String adminUsers = '$_base/admin/users';
  static String adminUser(String id) => '$_base/admin/users/$id';
  static const String adminProperties = '$_base/admin/properties';
  static const String adminAgents = '$_base/admin/agents';
}
