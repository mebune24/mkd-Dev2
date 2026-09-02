import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../core/api/api_endpoints.dart';
import '../../providers/di_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'application_update':
        return Icons.assignment_outlined;
      case 'lease_signed':
        return Icons.draw_outlined;
      case 'payment_due':
        return Icons.payment_outlined;
      case 'maintenance_update':
        return Icons.build_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'application_update':
        return Colors.blue;
      case 'lease_signed':
        return Colors.green;
      case 'payment_due':
        return Colors.orange;
      case 'maintenance_update':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) {
              if (notifications.any((n) => !n.isRead)) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () async {
                    try {
                      final client = ref.read(apiClientProvider);
                      await client.patch(ApiEndpoints.notificationsReadAll);
                      ref.invalidate(notificationsProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to mark all as read: $e')),
                        );
                      }
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            title: 'Failed to load notifications',
            message: e.toString(),
            icon: Icons.error_outline,
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(notificationsProvider),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return EmptyState(
                title: 'No Notifications',
                message: "You're all caught up! Check back later for updates.",
                icon: Icons.notifications_none_rounded,
                onAction: () => ref.invalidate(notificationsProvider),
                actionLabel: 'Refresh',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return InkWell(
                  onTap: () async {
                    if (!n.isRead) {
                      try {
                        final client = ref.read(apiClientProvider);
                        await client.patch(ApiEndpoints.notificationRead(n.id));
                        ref.invalidate(notificationsProvider);
                      } catch (_) {}
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: n.isRead ? Colors.white : Colors.blue.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border(
                        left: BorderSide(
                          color: n.isRead ? Colors.transparent : Colors.blue,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: _getColorForType(n.type).withValues(alpha: 0.1),
                          child: Icon(_getIconForType(n.type), color: _getColorForType(n.type)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
