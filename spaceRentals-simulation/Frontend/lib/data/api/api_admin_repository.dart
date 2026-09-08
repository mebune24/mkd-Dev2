import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/admin/domain/admin_transaction.dart';
import '../../providers/admin_users_provider.dart';

class ApiAdminRepository {
  final ApiClient _client;

  ApiAdminRepository(this._client);

  Future<AdminUserProfile> getUserProfile(String userId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.userById(userId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load user profile');
    }
    return AdminUserProfile.fromJson(response.data!);
  }

  Future<AdminUserProfile> setUserStatus(String userId, bool active) async {
    final response = await _client.patch<Map<String, dynamic>>(
      active
          ? ApiEndpoints.activateUser(userId)
          : ApiEndpoints.suspendUser(userId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to update user status',
      );
    }
    return AdminUserProfile.fromJson(response.data!);
  }

  Future<AdminReportsSummary> getReportsSummary() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.adminReportsSummary,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load reports');
    }
    return AdminReportsSummary.fromJson(response.data!);
  }

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
