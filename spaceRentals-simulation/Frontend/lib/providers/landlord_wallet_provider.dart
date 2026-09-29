import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api/api_landlord_wallet_repository.dart';
import '../providers/di_providers.dart';
import '../features/landlord/domain/landlord_wallet.dart';

final landlordWalletRepositoryProvider = Provider<ApiLandlordWalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiLandlordWalletRepository(apiClient);
});

final landlordWalletProvider = FutureProvider.autoDispose<LandlordWallet>((ref) async {
  final repo = ref.watch(landlordWalletRepositoryProvider);
  return await repo.getWallet();
});
