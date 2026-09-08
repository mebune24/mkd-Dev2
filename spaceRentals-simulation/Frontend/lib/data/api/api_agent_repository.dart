import '../../core/api/api_client.dart';
import '../../features/agents/domain/agent_models.dart';
import '../../features/landlord/domain/kyc_submission.dart';
import '../../core/api/api_endpoints.dart';

class ApiAgentRepository {
  final ApiClient _client;

  ApiAgentRepository(this._client);

  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  KYCSubmission _parseKyc(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map<String, dynamic>);
    final agent = json['agent'] is Map<String, dynamic>
        ? json['agent'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return KYCSubmission.fromJson({
      ...json,
      'user_id': json['agentId'] ?? agent['id'],
      'user_name': agent['name'] ?? 'Agent',
      'user_email': agent['email'] ?? '',
      'document_url': json['nationalIdUrl'] ?? '',
      'submitted_at': json['submittedAt'],
    });
  }

  Future<List<AgentProfile>> getAgents() async {
    final response = await _client.get(ApiEndpoints.agents);
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list
          .map((e) => AgentProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<AgentProfile> getProfile() async {
    final response = await _client.get(ApiEndpoints.agentProfile);
    return _unwrap(
      response,
      (data) => AgentProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<KYCSubmission> getMyKyc() async {
    final response = await _client.get(ApiEndpoints.agentMyKyc);
    return _unwrap(response, _parseKyc);
  }

  Future<void> submitKyc({
    required String nationalIdUrl,
    String? selfieUrl,
    String? businessDocUrl,
  }) async {
    final response = await _client.post(
      ApiEndpoints.agentKyc,
      data: {
        'nationalIdUrl': nationalIdUrl,
        if (selfieUrl != null) 'selfieUrl': selfieUrl,
        if (businessDocUrl != null) 'businessDocUrl': businessDocUrl,
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'KYC submission failed');
    }
  }

  Future<void> approveKyc(String id) async {
    final response = await _client.patch('/api/agents/kyc/$id/approve');
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'KYC approval failed');
    }
  }

  Future<void> rejectKyc(String id, {String? note}) async {
    final response = await _client.patch(
      '/api/agents/kyc/$id/reject',
      data: {'adminNote': note},
    );
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'KYC rejection failed');
    }
  }

  Future<List<KYCSubmission>> getPendingKyc() async {
    final response = await _client.get('${ApiEndpoints.agentKyc}/pending');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map(_parseKyc).toList();
    });
  }

  Future<List<KYCSubmission>> getAllKyc() async {
    final response = await _client.get(ApiEndpoints.agentKyc);
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map(_parseKyc).toList();
    });
  }

  Future<List<AgentTransaction>> getCommissions() async {
    final response = await _client.get(ApiEndpoints.agentCommissions);
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list
          .map((e) => AgentTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> requestWithdrawal({
    required int amount,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    final response = await _client.post(
      ApiEndpoints.agentWithdraw,
      data: {
        'amount': amount,
        'phoneNumber': phoneNumber,
        'paymentMethod': paymentMethod,
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'Withdrawal request failed');
    }
  }

  Future<AgentWallet> getWallet() async {
    final response = await _client.get(ApiEndpoints.agentWallet);
    return _unwrap(
      response,
      (data) => AgentWallet.fromJson(data as Map<String, dynamic>),
    );
  }
}
