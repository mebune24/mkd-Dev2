import '../features/agents/domain/agent_application.dart';
import '../features/auth/domain/user_profile.dart';

abstract class AgentRepository {
  Future<AgentKycApplication?> getMyKycApplication();
  Future<AgentKycApplication> submitKycApplication({
    required String nationalIdUrl,
    required String selfieUrl,
    String? businessDocUrl,
  });
  Future<List<AgentKycApplication>> getAllKycApplications({String? status});
  Future<AgentKycApplication> approveKycApplication(String applicationId);
  Future<AgentKycApplication> rejectKycApplication(String applicationId, {required String note});
  Future<AgentUserProfile?> getMyAgentProfile();
}
