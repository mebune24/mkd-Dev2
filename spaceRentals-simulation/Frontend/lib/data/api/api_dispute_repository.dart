import '../../core/api/api_client.dart';
import '../../features/rentals/domain/dispute_record.dart';

class ApiDisputeRepository {
  final ApiClient _client;

  ApiDisputeRepository(this._client);

  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  Future<List<DisputeRecord>> getDisputes() async {
    final response = await _client.get('/api/disputes');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => DisputeRecord.fromJson(e as Map<String, dynamic>)).toList();
    });
  }
}
