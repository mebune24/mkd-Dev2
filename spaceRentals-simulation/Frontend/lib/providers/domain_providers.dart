import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/landlord/domain/kyc_submission.dart';
import '../features/rentals/domain/dispute_record.dart';
import '../features/agents/domain/agent_models.dart';
import '../features/admin/domain/admin_transaction.dart';
import '../features/rentals/domain/rental.dart';
import '../core/domain/audit_entry.dart';
import '../models/user_model.dart';
import 'di_providers.dart';
import '../features/tenant/domain/tenant_wallet.dart';

// --- Users ---
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final response = await ref
      .read(apiClientProvider)
      .get<dynamic>('/api/admin/users');
  if (!response.isSuccess) {
    throw Exception(response.error?.message ?? 'Failed to load users');
  }
  final users = response.data is List
      ? response.data as List<dynamic>
      : const <dynamic>[];
  return users
      .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

// --- KYC Submissions ---
final kycSubmissionsProvider = FutureProvider<List<KYCSubmission>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  return repo.getAllKyc();
});

// --- Disputes ---
final disputesProvider = FutureProvider<List<DisputeRecord>>((ref) async {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getDisputes();
});

// --- Agent Profiles ---
final agentProfilesProvider = FutureProvider<List<AgentProfile>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  return repo.getAgents();
});

final currentAgentProfileProvider = FutureProvider<AgentProfile>((ref) async {
  return ref.watch(agentRepositoryProvider).getProfile();
});

// --- Admin Transactions ---
final adminTransactionsProvider = FutureProvider<AdminTransactionList>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getTransactions();
});

final tenantRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getTenantRentals();
});

final tenantWalletProvider = FutureProvider<TenantWallet>((ref) {
  return ref.watch(tenantWalletRepositoryProvider).getWallet();
});

final landlordRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getLandlordRentals();
});

// --- Agent Transactions ---
final agentTransactionsProvider = FutureProvider<List<AgentTransaction>>((
  ref,
) async {
  final repo = ref.watch(agentRepositoryProvider);
  return repo.getCommissions();
});

final agentWalletProvider = FutureProvider<AgentWallet>((ref) async {
  return ref.watch(agentRepositoryProvider).getWallet();
});

// --- Agent Agreements ---
final agentAgreementsProvider = FutureProvider<List<AgentServiceAgreement>>((
  ref,
) async {
  // Not implemented in backend MVP, returning empty for now
  return [];
});

// --- Audit Log ---
final auditLogProvider = FutureProvider<List<AuditEntry>>((ref) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getLogs();
});

final adminReportsProvider = FutureProvider<AdminReportsSummary>((ref) async {
  return ref.watch(adminRepositoryProvider).getReportsSummary();
});

// --- App Notifications ---
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

final appNotificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications();
});
