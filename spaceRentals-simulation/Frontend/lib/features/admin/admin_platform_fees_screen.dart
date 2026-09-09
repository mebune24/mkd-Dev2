import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/domain_providers.dart';

class AdminPlatformFeesScreen extends ConsumerWidget {
  const AdminPlatformFeesScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'due':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(adminPlatformFeesProvider);

    return feesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Platform Fees')),
        body: Center(child: Text('Error loading platform fees: $error')),
      ),
      data: (fees) {
        final total = fees.fold<int>(0, (sum, fee) => sum + fee.amount);
        return Scaffold(
          appBar: AppBar(title: const Text('Platform Fees')),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: 'Fees', value: '${fees.length}'),
                    _Stat(
                      label: 'Volume',
                      value: CurrencyFormatter.formatCFA(total.toDouble()),
                    ),
                    _Stat(
                      label: 'Paid',
                      value:
                          '${fees.where((f) => f.status.toLowerCase() == 'paid').length}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: fees.isEmpty
                    ? const Center(child: Text('No platform fees found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: fees.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final fee = fees[index];
                          return ListTile(
                            title: Text(
                              fee.landlordName ??
                                  fee.landlordEmail ??
                                  'Landlord',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fee.propertyTitle ?? fee.type.toUpperCase(),
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
                                          fee.status,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        fee.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(fee.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${fee.createdAt.day}/${fee.createdAt.month}/${fee.createdAt.year}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(
                              CurrencyFormatter.formatCFA(
                                fee.amount.toDouble(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
