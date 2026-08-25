import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/landlord/domain/kyc_submission.dart';
import '../features/rentals/domain/dispute_record.dart';
import '../features/agents/domain/agent_models.dart';
import '../core/domain/audit_entry.dart';
import '../models/user_model.dart';

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

  void resolve(String id, String resolution, {String? adminId, String? adminName, String? subject}) {}
  void setUnderReview(String id, {String? adminId, String? adminName, String? subject}) {}
  void resolveDispute(String id, String resolution) {
    final s = state.toList();
    final idx = s.indexWhere((element) => element.id == id);
    if (idx != -1) {
      s[idx].status = 'resolved';
      s[idx].resolution = resolution;
      state = s;
    }
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
