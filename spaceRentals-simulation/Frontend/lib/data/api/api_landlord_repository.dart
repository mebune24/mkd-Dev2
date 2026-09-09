import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/landlord/domain/landlord_dashboard_snapshot.dart';

class ApiLandlordRepository {
  final ApiClient _client;

  ApiLandlordRepository(this._client);

  Future<LandlordDashboardSnapshot> getDashboardSnapshot() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.landlordDashboard,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load landlord dashboard',
      );
    }
    return LandlordDashboardSnapshot.fromJson(response.data!);
  }
}
