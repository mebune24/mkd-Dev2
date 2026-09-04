import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audit_log_provider.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text('${logsAsync.length} entries', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: logsAsync.isEmpty
          ? const Center(child: Text('No audit entries yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logsAsync.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final log = logsAsync[i];
                final isLease = log.action == 'LEASE_SIGNED';
                final isPayment = log.action == 'PAYMENT_PROCESSED';
                final isApproval = log.action.startsWith('APPLICATION_');

                Color color = Colors.blueGrey;
                IconData icon = Icons.history;
                if (isLease) { color = Colors.indigo; icon = Icons.description; }
                if (isPayment) { color = Colors.green; icon = Icons.payments; }
                if (isApproval) { color = Colors.teal; icon = Icons.how_to_reg; }
                if (log.action == 'USER_LOGIN') { color = Colors.blue; icon = Icons.login; }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.1),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(log.action, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(log.targetDescription, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('By: ${log.actorName}  ·  ID: ${log.actorId}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(log.formattedTimestamp, style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace')),
                                ],
                              ),
                              if (isLease && log.metadata['signatureHash'] != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Hash: ${log.metadata['signatureHash']}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.indigo)),
                                      Text('Legal: ${log.metadata['legalFramework']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
