import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/admin/domain/admin_transaction.dart';
import '../../providers/admin_users_provider.dart';
import '../../features/landlord/domain/kyc_submission.dart';

class ApiAdminRepository {
  final ApiClient _client;

  ApiAdminRepository(this._client);

  Future<AdminOverviewSnapshot> getOverview() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.adminOverview,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load admin overview',
      );
    }
    return AdminOverviewSnapshot.fromJson(response.data!);
  }

  Future<void> createAdmin({
    required String name,
    required String email,
    required String temporaryPassword,
  }) async {
    final response = await _client.post(
      ApiEndpoints.adminUsers,
      data: {
        'name': name,
        'email': email,
        'temporaryPassword': temporaryPassword,
      },
    );
    if (!response.isSuccess)
      throw Exception(
        response.error?.message ?? 'Failed to create administrator',
      );
  }

  Future<int> bulkSuspendUsers(List<String> userIds) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${ApiEndpoints.adminUsers}/bulk-suspend',
      data: {'userIds': userIds},
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to suspend users');
    }
    return (response.data!['updatedCount'] as num?)?.toInt() ?? 0;
  }

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

  Future<List<AdminPlatformFee>> getPlatformFees() async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.adminPlatformFees,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load platform fees',
      );
    }
    return response.data!
        .whereType<Map>()
        .map(
          (item) => AdminPlatformFee.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<AdminSubscription>> getSubscriptions() async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.adminSubscriptions,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load subscriptions',
      );
    }
    return response.data!
        .whereType<Map>()
        .map(
          (item) => AdminSubscription.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<KYCSubmission>> getLandlordKyc() async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.adminLandlordVerification,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load landlord KYC');
    }
    return response.data!.whereType<Map>().map((item) {
      final json = Map<String, dynamic>.from(item);
      final landlord = json['landlord'] is Map
          ? Map<String, dynamic>.from(json['landlord'] as Map)
          : const <String, dynamic>{};
      return KYCSubmission.fromJson({
        ...json,
        'user_id': json['landlordId'] ?? landlord['id'],
        'user_name': landlord['name'] ?? 'Landlord',
        'user_email': landlord['email'] ?? '',
        'is_premium': json['tier'] == 'premium',
        'submitted_at': json['submittedAt'],
      });
    }).toList();
  }

  Future<void> approveLandlordKyc(String id) async {
    final response = await _client.patch(
      '${ApiEndpoints.adminLandlordVerification}/$id/approve',
    );
    if (!response.isSuccess) {
      throw Exception(
        response.error?.message ?? 'Landlord KYC approval failed',
      );
    }
  }

  Future<void> rejectLandlordKyc(String id, {String? note}) async {
    final response = await _client.patch(
      '${ApiEndpoints.adminLandlordVerification}/$id/reject',
      data: {'adminNote': note},
    );
    if (!response.isSuccess) {
      throw Exception(
        response.error?.message ?? 'Landlord KYC rejection failed',
      );
    }
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
