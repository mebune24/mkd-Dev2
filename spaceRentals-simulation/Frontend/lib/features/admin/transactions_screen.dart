import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/domain_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  Color _statusColor(String status) {
    final normalized = status.toUpperCase();
    switch (normalized) {
      case 'SUCCESSFUL':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT':
        return Icons.account_balance_wallet;
      case 'PAYOUT':
        return Icons.payments_outlined;
      case 'LEASE':
        return Icons.house_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(adminTransactionsProvider);

    return transactionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: Center(child: Text('Error loading transactions: $error')),
      ),
      data: (payload) {
        final txns = payload.transactions;
        final totalVolume = txns.fold<int>(0, (sum, txn) => sum + txn.amount);
        final pending = txns
            .where((txn) => txn.status.toUpperCase() == 'PENDING')
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('Transactions')),
          body: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Total Volume',
                      CurrencyFormatter.formatCFA(totalVolume.toDouble()),
                      Colors.white,
                    ),
                    _buildStat('Transactions', '${txns.length}', Colors.white),
                    _buildStat('Pending', '$pending', Colors.amberAccent),
                  ],
                ),
              ),
              Expanded(
                child: txns.isEmpty
                    ? const Center(child: Text('No transactions found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: txns.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final txn = txns[index];
                          final name = txn.userName ?? txn.userEmail ?? 'User';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(
                                _typeIcon(txn.transactionType),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatCFA(
                                    txn.amount.toDouble(),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${txn.transactionType} · ${txn.referenceType}',
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          txn.status,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        txn.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _statusColor(txn.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }
}
