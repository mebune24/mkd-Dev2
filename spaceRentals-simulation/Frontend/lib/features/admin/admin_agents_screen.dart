import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_endpoints.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../core/utils/ui_helpers.dart';

class AdminAgentsScreen extends ConsumerWidget {
  const AdminAgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final agents = ref.watch(agentProfilesProvider);
    final transactions = ref.watch(agentTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Manage Agents', style: TextStyle(fontWeight: FontWeight.bold)),
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
        elevation: 0,
      ),
      body: agents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading agents: $err')),
        data: (agentList) {
          if (agentList.isEmpty) {
            return const Center(child: Text('No agents registered yet.'));
          }
          
          return transactions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading transactions: $err')),
            data: (txList) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agentList.length,
                itemBuilder: (context, index) {
                  final agent = agentList[index];
                  final agentTx = txList.where((t) => t.agentId == agent.userId).toList();
                  final balance = agentTx.where((t) => t.status == 'Approved').fold(0.0, (s, t) => s + t.amount);
                  final pending = agentTx.where((t) => t.status == 'Pending').fold(0.0, (s, t) => s + t.amount);
                  return _AdminAgentCard(agent: agent, balance: balance, pending: pending);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminAgentCard extends ConsumerStatefulWidget {
  final AgentProfile agent;
  final double balance;
  final double pending;

  const _AdminAgentCard({required this.agent, required this.balance, required this.pending});

  @override
  ConsumerState<_AdminAgentCard> createState() => _AdminAgentCardState();
}

class _AdminAgentCardState extends ConsumerState<_AdminAgentCard> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agent = widget.agent;

    Color statusColor;
    switch (agent.status) {
      case 'active': statusColor = Colors.green; break;
      case 'pending': statusColor = Colors.orange; break;
      default: statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(Icons.real_estate_agent, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${agent.agentId} · ${agent.location}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(agent.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    if (agent.isWalletFrozen) ...[
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 11, color: Colors.red),
                          SizedBox(width: 3),
                          Text('Wallet Frozen', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(child: _StatCol(label: 'Properties', value: '${agent.propertiesVerified}')),
                  Container(width: 1, height: 28, color: Colors.grey.shade300),
                  Expanded(child: _StatCol(label: 'Tenants', value: '${agent.tenantsReferred}')),
                  Container(width: 1, height: 28, color: Colors.grey.shade300),
                  Expanded(child: _StatCol(label: 'Rating', value: '${agent.rating}⭐')),
                  Container(width: 1, height: 28, color: Colors.grey.shade300),
                  Expanded(child: _StatCol(label: 'Balance', value: CurrencyFormatter.formatCFA(widget.balance), color: Colors.green)),
                ],
              ),
            ),

            if (widget.pending > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.hourglass_empty, size: 13, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${CurrencyFormatter.formatCFA(widget.pending)} pending commission', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Action buttons
            Row(
              children: [
                if (agent.status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ref.read(agentProfilesProvider.notifier).reactivate(agent.agentId);
                        context.showSuccessToast('${agent.name} approved!');
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve KYC'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (agent.status == 'active') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // ref.read(agentProfilesProvider.notifier).suspend(agent.agentId);
                        context.showErrorToast('${agent.name} suspended.');
                      },
                      icon: const Icon(Icons.block, size: 16, color: Colors.orange),
                      label: const Text('Suspend', style: TextStyle(color: Colors.orange)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final token = ref.read(authProvider).session?.accessToken ?? '';
                        try {
                          if (agent.isWalletFrozen) {
                            await http.post(
                              Uri.parse(ApiEndpoints.unfreezeWallet(agent.userId)),
                              headers: {'Authorization': 'Bearer $token'},
                            );
                            context.showSuccessToast('${agent.name}\'s wallet unfrozen.');
                          } else {
                            await http.post(
                              Uri.parse(ApiEndpoints.freezeWallet(agent.userId)),
                              headers: {'Authorization': 'Bearer $token'},
                            );
                            context.showErrorToast('${agent.name}\'s wallet frozen.');
                          }
                          ref.invalidate(agentProfilesProvider);
                        } catch (e) {
                          context.showErrorToast('Failed to update wallet status');
                        }
                      },
                      icon: Icon(agent.isWalletFrozen ? Icons.lock_open : Icons.lock, size: 16, color: Colors.red),
                      label: Text(agent.isWalletFrozen ? 'Unfreeze' : 'Freeze Wallet', style: const TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
                if (agent.status == 'suspended') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ref.read(agentProfilesProvider.notifier).reactivate(agent.agentId);
                        context.showSuccessToast('${agent.name} reactivated!');
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('Reactivate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatCol({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color ?? Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}
