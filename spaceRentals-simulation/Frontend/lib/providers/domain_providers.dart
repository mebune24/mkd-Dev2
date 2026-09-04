import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/landlord/domain/kyc_submission.dart';
import '../features/rentals/domain/dispute_record.dart';
import '../features/agents/domain/agent_models.dart';
import '../core/domain/audit_entry.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api/api_endpoints.dart';
import '../services/session_storage_service.dart';
import 'di_providers.dart';

// --- Users ---
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  // Normally would fetch from admin users provider. 
  // But admin_users_provider.dart already exists, so this might be redundant.
  // Leaving empty list for now since users are handled by admin_users_provider.dart
  return [];
});

// --- KYC Submissions ---
final kycSubmissionsProvider = FutureProvider<List<KYCSubmission>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  return repo.getPendingKyc();
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

// --- Agent Transactions ---
final agentTransactionsProvider = FutureProvider<List<AgentTransaction>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  return repo.getCommissions();
});

// --- Agent Agreements ---
final agentAgreementsProvider = FutureProvider<List<AgentServiceAgreement>>((ref) async {
  // Not implemented in backend MVP, returning empty for now
  return [];
});

// --- Audit Log ---
final auditLogProvider = FutureProvider<List<AuditEntry>>((ref) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getLogs();
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
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

final appNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications();
});
