import '../features/wallet/domain/wallet.dart';

abstract class WalletRepository {
  Future<Wallet> getWallet();
  Future<Withdrawal> requestWithdrawal(RequestWithdrawalRequest request);
  Future<Withdrawal> getWithdrawal(String withdrawalId);
  Future<List<Withdrawal>> getWithdrawals();
  Future<Wallet> freezeWallet(String agentId);
  Future<Wallet> unfreezeWallet(String agentId);
}
