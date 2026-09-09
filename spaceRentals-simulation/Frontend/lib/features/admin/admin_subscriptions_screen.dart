import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/domain_providers.dart';

class AdminSubscriptionsScreen extends ConsumerWidget {
  const AdminSubscriptionsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'grace_period':
      case 'payment_due':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(adminSubscriptionsProvider);

    return subscriptionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Subscriptions')),
        body: Center(child: Text('Error loading subscriptions: $error')),
      ),
      data: (subscriptions) {
        final active = subscriptions
            .where((s) => s.status.toLowerCase() == 'active')
            .length;
        final expirations = subscriptions
            .where((s) => s.status.toLowerCase() == 'expired')
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('Subscriptions')),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: 'Total', value: '${subscriptions.length}'),
                    _Stat(label: 'Active', value: '$active'),
                    _Stat(label: 'Expired', value: '$expirations'),
                  ],
                ),
              ),
              Expanded(
                child: subscriptions.isEmpty
                    ? const Center(
                        child: Text('No subscription records found.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: subscriptions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sub = subscriptions[index];
                          return ListTile(
                            title: Text(
                              sub.landlordName ??
                                  sub.landlordEmail ??
                                  'Landlord',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Plan: ${sub.planId.toUpperCase()}'),
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
                                          sub.status,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        sub.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(sub.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${sub.activeListingCount} active listings',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Expires',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${sub.expiresAt.day}/${sub.expiresAt.month}/${sub.expiresAt.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
