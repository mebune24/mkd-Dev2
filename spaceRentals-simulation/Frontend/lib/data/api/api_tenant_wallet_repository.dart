import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/tenant/domain/tenant_wallet.dart';

class ApiTenantWalletRepository {
  final ApiClient _client;
  ApiTenantWalletRepository(this._client);

  Future<TenantWallet> getWallet() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.tenantWallet);
    if (!response.isSuccess || response.data == null) throw Exception(response.error?.message ?? 'Unable to load wallet');
    return TenantWallet.fromJson(response.data!);
  }

  Future<TenantWallet> applyToRent(int amount) async {
    final response = await _client.post<Map<String, dynamic>>(ApiEndpoints.tenantWalletApplyToRent, data: {'amount': amount});
    if (!response.isSuccess || response.data == null) throw Exception(response.error?.message ?? 'Unable to apply balance');
    return getWallet();
  }

  Future<TenantWallet> withdraw({required int amount, required String method, required String destination}) async {
    final response = await _client.post<Map<String, dynamic>>(ApiEndpoints.tenantWalletWithdraw, data: {'amount': amount, 'method': method, 'destination': destination});
    if (!response.isSuccess) throw Exception(response.error?.message ?? 'Unable to request withdrawal');
    return getWallet();
  }
}
