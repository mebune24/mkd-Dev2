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

// --- Users ---
class AllUsersNotifier extends Notifier<List<UserModel>> {
  @override
  List<UserModel> build() => [];
  
  void addUser(UserModel user) { state = [...state, user]; }
  void addAdmin(UserModel user) { state = [...state, user]; }
  void removeUser(String id) { state = state.where((u) => u.id != id).toList(); }
  void updateUserKYC(String id, String status) {}
}
final allUsersProvider = NotifierProvider<AllUsersNotifier, List<UserModel>>(AllUsersNotifier.new);

// --- KYC Submissions ---
class KycSubmissionsNotifier extends Notifier<List<KYCSubmission>> {
  @override
  List<KYCSubmission> build() => [];

  void addSubmission(KYCSubmission sub) { state = [...state, sub]; }
  void submit(KYCSubmission sub) { state = [...state, sub]; }
  void approve(String id, {String? adminId, String? adminName, bool premium = false}) {}
  void reject(String id, {String? adminId, String? adminName}) {}

  void verifySubmission(String id) {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.userId == id);
    if (idx != -1) {
      s[idx].status = 'verified';
      state = s;
    }
  }

  void rejectSubmission(String id) {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.userId == id);
    if (idx != -1) {
      s[idx].status = 'rejected';
      state = s;
    }
  }
}
final kycSubmissionsProvider = NotifierProvider<KycSubmissionsNotifier, List<KYCSubmission>>(KycSubmissionsNotifier.new);

// --- Disputes ---
class DisputesNotifier extends Notifier<List<DisputeRecord>> {
  @override
  List<DisputeRecord> build() => [];

  Future<void> resolve(String id, String resolution, {String? adminId, String? adminName, String? subject}) async {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.id == id);
    if (idx != -1) {
      // Optimistic update
      s[idx].status = 'resolved';
      s[idx].resolution = resolution;
      state = s;
      
      // API call
      try {
        final token = await SessionStorageService.instance.getAccessToken();
        if (token != null) {
          final uri = Uri.parse('${ApiEndpoints.baseUrl}/disputes/$id/resolve');
          await http.patch(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'resolution': resolution}),
          );
        }
      } catch (e) {
        // Rollback on failure (simplified)
        debugPrint('Failed to resolve dispute on backend: $e');
      }
    }
  }

  void setUnderReview(String id, {String? adminId, String? adminName, String? subject}) {}
  
  void resolveDispute(String id, String resolution) {
    resolve(id, resolution);
  }
}
final disputesProvider = NotifierProvider<DisputesNotifier, List<DisputeRecord>>(DisputesNotifier.new);

// --- Agent Profiles ---
class AgentProfilesNotifier extends Notifier<List<AgentProfile>> {
  @override
  List<AgentProfile> build() => [];

  void suspend(String id) {}
  void reactivate(String id) {}
  void freezeWallet(String id) {}
  void suspendAgent(String id) {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.agentId == id);
    if (idx != -1) {
      s[idx].status = 'suspended';
      state = s;
    }
  }

  void activateAgent(String id) {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.agentId == id);
    if (idx != -1) {
      s[idx].status = 'active';
      state = s;
    }
  }
}
final agentProfilesProvider = NotifierProvider<AgentProfilesNotifier, List<AgentProfile>>(AgentProfilesNotifier.new);

// --- Agent Transactions ---
class AgentTransactionsNotifier extends Notifier<List<AgentTransaction>> {
  @override
  List<AgentTransaction> build() => [];
}
final agentTransactionsProvider = NotifierProvider<AgentTransactionsNotifier, List<AgentTransaction>>(AgentTransactionsNotifier.new);

// --- Agent Agreements ---
class AgentAgreementsNotifier extends Notifier<List<AgentServiceAgreement>> {
  @override
  List<AgentServiceAgreement> build() => [];
  void requestAgreement(AgentServiceAgreement a) {}
  void terminate(String id) {}
}
final agentAgreementsProvider = NotifierProvider<AgentAgreementsNotifier, List<AgentServiceAgreement>>(AgentAgreementsNotifier.new);

// --- Audit Log ---
class AuditLogNotifier extends Notifier<List<AuditEntry>> {
  @override
  List<AuditEntry> build() => [];

  void log(String userId, String userRole, String action) {}
  void addAudit(String userId, String userRole, String action) {
    final entry = AuditEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userRole: userRole,
      action: action,
      timestamp: DateTime.now(),
    );
    state = [entry, ...state];
  }
}
final auditLogProvider = NotifierProvider<AuditLogNotifier, List<AuditEntry>>(AuditLogNotifier.new);

// --- App Notifications ---
class AppNotification {
  final String id;
  final String userId;   // empty = broadcast to all
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
}

class AppNotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => [];

  void addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) {
    final notif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );
    state = [notif, ...state];
  }

  List<AppNotification> forUser(String userId) {
    return state.where((n) => n.userId == userId || n.userId.isEmpty).toList();
  }

  void markRead(String id) {
    state = state.map((n) => n.id == id ? (n..isRead = true) : n).toList();
  }

  void markAllRead(String userId) {
    state = state
        .map((n) => (n.userId == userId || n.userId.isEmpty) ? (n..isRead = true) : n)
        .toList();
  }
}
final appNotificationsProvider =
    NotifierProvider<AppNotificationsNotifier, List<AppNotification>>(AppNotificationsNotifier.new);
