import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di_providers.dart';
import '../data/api/api_payment_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────
/// Fetches all transactions for the current user
final myTransactionsProvider = FutureProvider<List<TransactionRecord>>((
  ref,
) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getMyTransactions();
});

/// Landlord transactions
final landlordTransactionsProvider = FutureProvider<List<TransactionRecord>>((
  ref,
) async {
  return ref.watch(paymentRepositoryProvider).getLandlordTransactions();
});

final landlordPendingTransactionsProvider =
    FutureProvider<List<TransactionRecord>>((ref) async {
      final all = await ref.watch(landlordTransactionsProvider.future);
      return all
          .where((transaction) => transaction.status == 'PENDING')
          .toList();
    });

final landlordSuccessfulTransactionsProvider =
    FutureProvider<List<TransactionRecord>>((ref) async {
      final all = await ref.watch(landlordTransactionsProvider.future);
      return all
          .where((transaction) => transaction.status == 'SUCCESSFUL')
          .toList();
    });

final landlordTotalRevenueProvider = FutureProvider<double>((ref) async {
  final successful = await ref.watch(
    landlordSuccessfulTransactionsProvider.future,
  );
  return successful.fold<double>(
    0,
    (sum, transaction) => sum + transaction.amount,
  );
});

/// Pending transactions
final pendingTransactionsProvider = FutureProvider<List<TransactionRecord>>((
  ref,
) async {
  final all = await ref.watch(myTransactionsProvider.future);
  return all.where((p) => p.status == 'PENDING').toList();
});

/// Successful transactions
final successfulTransactionsProvider = FutureProvider<List<TransactionRecord>>((
  ref,
) async {
  final all = await ref.watch(myTransactionsProvider.future);
  return all.where((p) => p.status == 'SUCCESSFUL').toList();
});

/// Total Revenue
final totalRevenueProvider = FutureProvider<double>((ref) async {
  final successful = await ref.watch(successfulTransactionsProvider.future);
  double sum = 0.0;
  for (var p in successful) {
    sum += p.amount;
  }
  return sum;
});
