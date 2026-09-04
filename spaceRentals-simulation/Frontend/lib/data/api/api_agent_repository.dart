import '../../core/api/api_client.dart';
import '../../features/agents/domain/agent_models.dart';
import '../../features/landlord/domain/kyc_submission.dart';

class ApiAgentRepository {
  final ApiClient _client;

  ApiAgentRepository(this._client);

  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  Future<List<AgentProfile>> getAgents() async {
    final response = await _client.get('/api/agents');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => AgentProfile.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<AgentProfile> getProfile() async {
    final response = await _client.get('/api/agents/profile');
    return _unwrap(response, (data) => AgentProfile.fromJson(data as Map<String, dynamic>));
  }

  Future<KYCSubmission> getMyKyc() async {
    final response = await _client.get('/api/agents/kyc/me');
    return _unwrap(response, (data) => KYCSubmission.fromJson(data as Map<String, dynamic>));
  }

  Future<List<KYCSubmission>> getPendingKyc() async {
    final response = await _client.get('/api/agents/kyc/pending');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => KYCSubmission.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<KYCSubmission>> getAllKyc() async {
    final response = await _client.get('/api/agents/kyc');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => KYCSubmission.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<List<AgentTransaction>> getCommissions() async {
    final response = await _client.get('/api/agents/commissions');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => AgentTransaction.fromJson(e as Map<String, dynamic>)).toList();
    });
  }
}
