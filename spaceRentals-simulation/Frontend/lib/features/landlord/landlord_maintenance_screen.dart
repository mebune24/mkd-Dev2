import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_endpoints.dart';
import '../../providers/di_providers.dart';
import '../../widgets/empty_state.dart';
import '../tenant/maintenance_screen.dart' show MaintenanceModel, maintenanceProvider;

class LandlordMaintenanceScreen extends ConsumerWidget {
  const LandlordMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Maintenance Requests'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(maintenanceProvider),
        child: maintenanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            title: 'Could not load requests',
            message: e.toString(),
            icon: Icons.error_outline,
            onAction: () => ref.invalidate(maintenanceProvider),
            actionLabel: 'Retry',
          ),
          data: (requests) => requests.isEmpty
              ? const EmptyState(
                  title: 'No maintenance requests',
                  message: 'Your tenants have not submitted any maintenance requests yet.',
                  icon: Icons.build_circle_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    return _LandlordMaintenanceCard(
                      request: r,
                      onUpdate: (status, note) async {
                        await _updateRequest(context, ref, r.id, status, note);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _updateRequest(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
    String? note,
  ) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(
        ApiEndpoints.maintenanceRequest(id),
        data: {
          'status': status,
          if (note != null && note.isNotEmpty) 'landlordNote': note,
        },
      );
      ref.invalidate(maintenanceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }
}

class _LandlordMaintenanceCard extends StatelessWidget {
  final MaintenanceModel request;
  final Future<void> Function(String status, String? note) onUpdate;

  const _LandlordMaintenanceCard({
    required this.request,
    required this.onUpdate,
  });

  Color _urgencyColor() {
    switch (request.urgency) {
      case 'Emergency': return Colors.red;
      case 'High': return Colors.orange;
      case 'Low': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color _statusColor() {
    switch (request.status) {
      case 'resolved': case 'closed': return Colors.green;
      case 'in_progress': return Colors.blue;
      case 'acknowledged': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _showUpdateDialog(BuildContext context) {
    String selectedStatus = request.status;
    final noteCtrl = TextEditingController(text: request.landlordNote ?? '');
    const statuses = ['open', 'acknowledged', 'in_progress', 'resolved', 'closed'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setS) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Update: ${request.title}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: statuses.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceAll('_', ' ').toUpperCase()),
                  )).toList(),
                  onChanged: (v) => setS(() => selectedStatus = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note to Tenant (optional)',
                    hintText: 'e.g. Plumber scheduled for Thursday 2pm',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await onUpdate(selectedStatus, noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Update Request', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        border: Border(left: BorderSide(color: _urgencyColor(), width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(fontSize: 10, color: _statusColor(), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.description,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(request.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _urgencyColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.urgency,
                    style: TextStyle(fontSize: 11, color: _urgencyColor(), fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                // Action button
                TextButton.icon(
                  onPressed: () => _showUpdateDialog(context),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Update', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
            if (request.landlordNote != null && request.landlordNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your note: ${request.landlordNote}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
