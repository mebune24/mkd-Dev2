import '../../core/api/api_client.dart';
import '../../core/domain/audit_entry.dart';

class ApiAuditRepository {
  final ApiClient _client;

  ApiAuditRepository(this._client);

  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  Future<List<AuditEntry>> getLogs() async {
    final response = await _client.get(
      '/api/audit-logs',
      queryParameters: {'limit': '100'},
    );
    return _unwrap(response, (data) {
      final list = data is List ? data : const <dynamic>[];
      return list
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
