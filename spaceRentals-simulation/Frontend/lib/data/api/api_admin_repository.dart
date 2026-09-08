import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/admin/domain/admin_transaction.dart';

class ApiAdminRepository {
  final ApiClient _client;

  ApiAdminRepository(this._client);

  Future<AdminTransactionList> getTransactions({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.adminUsers.replaceAll('/users', '/transactions'),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load admin transactions',
      );
    }

    return AdminTransactionList.fromJson(response.data!);
  }
}
