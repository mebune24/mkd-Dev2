import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'RNLP Repayment':
        return Icons.account_balance;
      case 'Deposit':
        return Icons.savings;
      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txns = []; // TODO: ref.watch(agentTransactionsProvider) and map it

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Summary bar
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total Volume', CurrencyFormatter.formatCFA(600000), Colors.white),
                _buildStat('Transactions', '${txns.length}', Colors.white),
                _buildStat('Pending', '1', Colors.amberAccent),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: txns.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final txn = txns[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(_typeIcon(txn['type']), color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(txn['tenant'], style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text(
                        CurrencyFormatter.formatCFA(txn['amount']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${txn['type']} · ${txn['property']}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(txn['status']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              txn['status'].toUpperCase(),
                              style: TextStyle(fontSize: 10, color: _statusColor(txn['status']), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(txn['date'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }
}
