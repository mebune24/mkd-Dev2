import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/rnlp_model.dart';

class ApiRnlpRepository {
  final ApiClient _client;

  ApiRnlpRepository(this._client);

  Future<RnlpModel?> getOrCreateContract() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.rnlpMe,
    );
    if (!response.isSuccess) {
      throw Exception(
        response.error?.message ?? 'Failed to load RNLP contract',
      );
    }
    if (response.data == null) return null;
    return RnlpModel.fromJson(response.data!);
  }

  Future<void> markInstalmentPending(String instalmentId) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.rnlpInstalmentPayment(instalmentId),
    );
    if (!response.isSuccess) {
      throw Exception(
        response.error?.message ?? 'Failed to prepare instalment payment',
      );
    }
  }
}
