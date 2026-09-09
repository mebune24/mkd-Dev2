import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tenant/maintenance_screen.dart';
import '../../core/api/api_endpoints.dart';
import '../../providers/di_providers.dart';

final adminMaintenanceProvider = FutureProvider<List<MaintenanceModel>>((
  ref,
) async {
  final response = await ref
      .read(apiClientProvider)
      .get<dynamic>(ApiEndpoints.maintenance);
  if (!response.isSuccess)
    throw Exception(response.error?.message ?? 'Failed to load maintenance');
  final data = response.data;
  final list = data is Map && data['data'] is List
      ? data['data'] as List
      : data is List
      ? data
      : const <dynamic>[];
  return list
      .map(
        (item) =>
            MaintenanceModel.fromJson(Map<String, dynamic>.from(item as Map)),
      )
      .toList();
});

class AdminMaintenanceOperationsScreen extends ConsumerWidget {
  const AdminMaintenanceOperationsScreen({super.key});

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    MaintenanceModel request,
    String status,
  ) async {
    final response = await ref
        .read(apiClientProvider)
        .patch(
          '${ApiEndpoints.maintenance}/${request.id}',
          data: {'status': status},
        );
    if (!response.isSuccess) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error?.message ?? 'Update failed')),
        );
      return;
    }
    ref.invalidate(adminMaintenanceProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(adminMaintenanceProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Maintenance Operations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminMaintenanceProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load maintenance: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No maintenance requests.'))
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.refresh(adminMaintenanceProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _StatusChip(status: item.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${item.category} · ${item.urgency}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (item.status == 'open')
                                  OutlinedButton(
                                    onPressed: () => _update(
                                      context,
                                      ref,
                                      item,
                                      'acknowledged',
                                    ),
                                    child: const Text('Acknowledge'),
                                  ),
                                if (item.status == 'acknowledged')
                                  OutlinedButton(
                                    onPressed: () => _update(
                                      context,
                                      ref,
                                      item,
                                      'in_progress',
                                    ),
                                    child: const Text('Start'),
                                  ),
                                if (item.status == 'in_progress')
                                  FilledButton(
                                    onPressed: () =>
                                        _update(context, ref, item, 'resolved'),
                                    child: const Text('Resolve'),
                                  ),
                                if (item.status == 'resolved')
                                  OutlinedButton(
                                    onPressed: () =>
                                        _update(context, ref, item, 'closed'),
                                    child: const Text('Close'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: const TextStyle(fontSize: 10),
    ),
    visualDensity: VisualDensity.compact,
  );
}
