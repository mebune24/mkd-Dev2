import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class Wallet {
  final String id;
  final String agentId;
  final Money pendingBalance;
  final Money eligibleBalance;
  final Money availableBalance;
  final Money withdrawnBalance;
  final WalletStatus status;

  const Wallet({
    required this.id,
    required this.agentId,
    required this.pendingBalance,
    required this.eligibleBalance,
    required this.availableBalance,
    required this.withdrawnBalance,
    required this.status,
  });

  bool get isFrozen => status == WalletStatus.frozen;
  bool get canWithdraw => status == WalletStatus.active && availableBalance >= Money.zero;
}

class Withdrawal {
  final String id;
  final String agentId;
  final Money amount;
  final PaymentMethod method;
  final String phoneNumber;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? paidAt;

  const Withdrawal({
    required this.id,
    required this.agentId,
    required this.amount,
    required this.method,
    required this.phoneNumber,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.paidAt,
  });
}

class RequestWithdrawalRequest {
  final int amountUnits;
  final PaymentMethod method;
  final String phoneNumber;
  final String? idempotencyKey;

  const RequestWithdrawalRequest({
    required this.amountUnits,
    required this.method,
    required this.phoneNumber,
    this.idempotencyKey,
  });
}
