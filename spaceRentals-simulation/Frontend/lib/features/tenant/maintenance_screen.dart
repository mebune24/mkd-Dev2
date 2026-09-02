import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_endpoints.dart';
import '../../providers/di_providers.dart';
import '../../widgets/empty_state.dart';

class MaintenanceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String urgency;
  final String status;
  final String? landlordNote;
  final DateTime createdAt;

  MaintenanceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    this.landlordNote,
    required this.createdAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'General',
      urgency: json['urgency'] as String? ?? 'Normal',
      status: json['status'] as String,
      landlordNote: json['landlordNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

final maintenanceProvider = FutureProvider<List<MaintenanceModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get<dynamic>(ApiEndpoints.maintenance);
  if (response.data == null) return [];
  final data = response.data as Map<String, dynamic>;
  final list = data['data'] as List<dynamic>? ?? [];
  return list.map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>)).toList();
});

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maintenanceAsync = ref.watch(maintenanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Maintenance Requests'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
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
              ? EmptyState(
                  title: 'No maintenance requests',
                  message: 'Submit a request when something needs fixing in your rental.',
                  icon: Icons.build_outlined,
                  onAction: () => _showSubmitDialog(context),
                  actionLabel: 'Submit First Request',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    return _MaintenanceCard(request: r, theme: theme);
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _showSubmitDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCategory = 'General';
    String selectedUrgency = 'Normal';
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
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
                    const Text('Submit Maintenance Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Leaking tap in kitchen', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: ['Plumbing', 'Electrical', 'Structural', 'Appliance', 'General']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setS(() => selectedCategory = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUrgency,
                        decoration: const InputDecoration(labelText: 'Urgency', border: OutlineInputBorder()),
                        items: ['Low', 'Normal', 'High', 'Emergency']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setS(() => selectedUrgency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                    setS(() => isLoading = true);
                    try {
                      final client = ref.read(apiClientProvider);
                      // TODO: we need to pass rentalId here, but for now we'll just try
                      await client.post(ApiEndpoints.maintenance, data: {
                        'rentalId': 'placeholder-will-fail-backend-check', 
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'category': selectedCategory,
                        'urgency': selectedUrgency,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      ref.invalidate(maintenanceProvider);
                    } catch (e) {
                      setS(() => isLoading = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceModel request;
  final ThemeData theme;
  const _MaintenanceCard({required this.request, required this.theme});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(request.status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 10, color: _statusColor(), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(request.description, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  decoration: BoxDecoration(color: _urgencyColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(request.urgency, style: TextStyle(fontSize: 11, color: _urgencyColor(), fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Text(
                  '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                    Expanded(child: Text('Landlord: ${request.landlordNote}', style: const TextStyle(fontSize: 12, color: Colors.blue))),
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
