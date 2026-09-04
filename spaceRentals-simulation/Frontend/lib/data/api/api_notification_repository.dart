import '../../core/api/api_client.dart';
import '../../providers/domain_providers.dart';

class ApiNotificationRepository {
  final ApiClient _client;

  ApiNotificationRepository(this._client);

  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _client.get('/api/notifications');
    return _unwrap(response, (data) {
      final list = (data is Map ? data['data'] : data) as List<dynamic>? ?? [];
      return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    });
  }
}
