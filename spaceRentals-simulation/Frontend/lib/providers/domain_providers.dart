import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/landlord/domain/kyc_submission.dart';
import '../features/rentals/domain/dispute_record.dart';

import '../features/admin/domain/admin_transaction.dart';
import '../features/rentals/domain/rental.dart';
import '../core/domain/audit_entry.dart';
import '../models/user_model.dart';
import 'di_providers.dart';
import '../features/tenant/domain/tenant_wallet.dart';
import '../features/landlord/domain/landlord_dashboard_snapshot.dart';

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


final landlordKycSubmissionsProvider = FutureProvider<List<KYCSubmission>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getLandlordKyc();
});

// --- KYC Submissions (via admin repository) ---
final kycSubmissionsProvider = FutureProvider<List<KYCSubmission>>((ref) async {
  return ref.watch(adminRepositoryProvider).getLandlordKyc();
});

// --- Disputes ---
final disputesProvider = FutureProvider<List<DisputeRecord>>((ref) async {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getDisputes();
});

// --- Landlord Dashboard ---
final landlordDashboardProvider = FutureProvider<LandlordDashboardSnapshot>((ref) {
  return ref.watch(landlordRepositoryProvider).getDashboardSnapshot();
});

// --- Admin Transactions ---
final adminTransactionsProvider = FutureProvider<AdminTransactionList>((ref) async {
  return ref.watch(adminRepositoryProvider).getTransactions();
});

// --- Rentals ---
final tenantRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  return ref.watch(rentalRepositoryProvider).getTenantRentals();
});

final landlordRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  return ref.watch(rentalRepositoryProvider).getLandlordRentals();
});

// --- Tenant Wallet ---
final tenantWalletProvider = FutureProvider<TenantWallet>((ref) {
  return ref.watch(tenantWalletRepositoryProvider).getWallet();
});

final auditLogProvider = FutureProvider<List<AuditEntry>>((ref) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getLogs();
});

final adminReportsProvider = FutureProvider<AdminReportsSummary>((ref) async {
  return ref.watch(adminRepositoryProvider).getReportsSummary();
});

final adminPlatformFeesProvider = FutureProvider<List<AdminPlatformFee>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).getPlatformFees();
});

final adminSubscriptionsProvider = FutureProvider<List<AdminSubscription>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).getSubscriptions();
});

final adminOverviewProvider = FutureProvider<AdminOverviewSnapshot>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).getOverview();
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
