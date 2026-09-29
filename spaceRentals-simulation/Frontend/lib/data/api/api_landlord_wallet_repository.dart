import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/landlord/domain/landlord_wallet.dart';

class ApiLandlordWalletRepository {
  final ApiClient _client;
  
  ApiLandlordWalletRepository(this._client);

  Future<LandlordWallet> getWallet() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.landlordWallet);
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Unable to load wallet');
    }
    return LandlordWallet.fromJson(response.data!);
  }

  Future<void> requestWithdrawal(double amount, String method, String destination) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.landlordWalletWithdraw,
      data: {
        'amount': amount,
        'method': method,
        'destination': destination,
      },
    );
    
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'Unable to request withdrawal');
    }
  }
}
