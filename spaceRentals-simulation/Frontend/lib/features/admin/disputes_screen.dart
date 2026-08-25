import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/ui_helpers.dart';

// ── Dispute Model ─────────────────────────────────────────────────────────────
enum DisputeStatus { open, underReview, resolved }

class Dispute {
  final String id;
  final String raisedBy;
  final String raisedByRole;
  final String againstParty;
  final String subject;
  final String description;
  final DateTime createdAt;
  DisputeStatus status;
  String? resolution;

  Dispute({
    required this.id,
    required this.raisedBy,
    required this.raisedByRole,
    required this.againstParty,
    required this.subject,
    required this.description,
    required this.createdAt,
    this.status = DisputeStatus.open,
    this.resolution,
  });
}

class DisputesNotifier extends Notifier<List<Dispute>> {
  @override
  List<Dispute> build() {
    return [
      Dispute(
        id: 'DIS-001',
        raisedBy: 'Alice Nguema (Tenant)',
        raisedByRole: 'Tenant',
        againstParty: 'Landlord: John Doe',
        subject: 'Security deposit not returned',
        description: 'I vacated the property on 30 July 2026 after giving 30 days notice. The landlord has not returned my 300,000 CFA security deposit. The apartment was left in perfect condition.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: DisputeStatus.underReview,
      ),
      Dispute(
        id: 'DIS-002',
        raisedBy: 'Jean-Pierre Mballa (Landlord)',
        raisedByRole: 'Landlord',
        againstParty: 'Tenant: Christine Ekoka',
        subject: 'Rent arrears — 2 months overdue',
        description: 'My tenant has not paid rent for August and September 2026. She is not responding to messages or calls. Total owed: 160,000 CFA.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        status: DisputeStatus.open,
      ),
      Dispute(
        id: 'DIS-003',
        raisedBy: 'Marie Atangana (Tenant)',
        raisedByRole: 'Tenant',
        againstParty: 'Landlord: Ambe Properties',
        subject: 'Water supply cut without notice',
        description: 'The landlord cut water to the building on 10 August 2026 without prior notice. This has persisted for 5 days and is a breach of the rental agreement.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: DisputeStatus.resolved,
        resolution: 'Landlord was contacted and water supply restored within 24 hours. Warning issued.',
      ),
    ];
  }

  void updateStatus(String id, DisputeStatus status, {String? resolution}) {
    state = state.map((d) {
      if (d.id == id) {
        d.status = status;
        if (resolution != null) d.resolution = resolution;
        return d;
      }
      return d;
    }).toList();
  }
}

final disputesProvider = NotifierProvider<DisputesNotifier, List<Dispute>>(() {
  return DisputesNotifier();
});

// ── Disputes Screen ───────────────────────────────────────────────────────────
class DisputesScreen extends ConsumerWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputes = ref.watch(disputesProvider);
    final theme = Theme.of(context);

    final open = disputes.where((d) => d.status == DisputeStatus.open).length;
    final review = disputes.where((d) => d.status == DisputeStatus.underReview).length;
    final resolved = disputes.where((d) => d.status == DisputeStatus.resolved).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Resolution'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Open', '$open', Colors.red),
                _buildStat('Under Review', '$review', Colors.orange),
                _buildStat('Resolved', '$resolved', Colors.green),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: disputes.isEmpty
                ? const Center(child: Text('No disputes filed.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: disputes.length,
                    itemBuilder: (context, i) {
                      return _DisputeCard(dispute: disputes[i]);
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
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DisputeCard extends ConsumerStatefulWidget {
  final Dispute dispute;
  const _DisputeCard({required this.dispute});

  @override
  ConsumerState<_DisputeCard> createState() => _DisputeCardState();
}

class _DisputeCardState extends ConsumerState<_DisputeCard> {
  bool _expanded = false;

  Color _statusColor(DisputeStatus s) {
    switch (s) {
      case DisputeStatus.open: return Colors.red;
      case DisputeStatus.underReview: return Colors.orange;
      case DisputeStatus.resolved: return Colors.green;
    }
  }

  String _statusLabel(DisputeStatus s) {
    switch (s) {
      case DisputeStatus.open: return 'Open';
      case DisputeStatus.underReview: return 'Under Review';
      case DisputeStatus.resolved: return 'Resolved';
    }
  }

  void _showResolveDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide a resolution note for both parties:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Resolution details...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              ref.read(disputesProvider.notifier).updateStatus(
                widget.dispute.id,
                DisputeStatus.resolved,
                resolution: controller.text.trim(),
              );
              Navigator.pop(ctx);
              context.showToast('Dispute marked as resolved. Both parties notified.');
            },
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    final theme = Theme.of(context);
    final color = _statusColor(d.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(Icons.gavel, color: color),
            ),
            title: Text(d.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${d.raisedBy} vs ${d.againstParty}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(_statusLabel(d.status), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('ID: ${d.id}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            trailing: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
            isThreeLine: true,
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 6),
                  Text(d.description, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text('Filed: ${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (d.resolution != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(d.resolution!, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                        ],
                      ),
                    ),
                  ],
                  if (d.status != DisputeStatus.resolved) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (d.status == DisputeStatus.open)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => ref.read(disputesProvider.notifier).updateStatus(d.id, DisputeStatus.underReview),
                              icon: const Icon(Icons.rate_review, size: 16),
                              label: const Text('Start Review'),
                            ),
                          ),
                        if (d.status == DisputeStatus.open) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showResolveDialog,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Resolve'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
