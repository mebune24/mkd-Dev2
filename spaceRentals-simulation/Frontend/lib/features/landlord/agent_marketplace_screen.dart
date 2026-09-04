import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../../providers/auth_provider.dart';
import '../../core/utils/ui_helpers.dart';

class AgentMarketplaceScreen extends ConsumerWidget {
  const AgentMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final agentProfilesAsync = ref.watch(agentProfilesProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Agent Directory', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: agentProfilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load agents: $err')),
        data: (agents) {
          final activeAgents = agents.where((a) => a.status == 'active').toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All agents are verified by SpaceRentals. Contact details are only visible after an active service agreement.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('${activeAgents.length} Verified Agents', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...activeAgents.map((agent) => _AgentCard(
                agent: agent,
                landlordId: user.session?.userId ?? '',
                landlordName: user.session?.fullName ?? '',
              )),
            ],
          );
        },
      ),
    );
  }
}

class _AgentCard extends ConsumerStatefulWidget {
  final AgentProfile agent;
  final String landlordId;
  final String landlordName;

  const _AgentCard({required this.agent, required this.landlordId, required this.landlordName});

  @override
  ConsumerState<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends ConsumerState<_AgentCard> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agent = widget.agent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    agent.name.isNotEmpty ? agent.name[0] : '?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 11, color: Colors.green),
                                SizedBox(width: 3),
                                Text('Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(agent.agentId, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(agent.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(child: _AgentStat(label: 'Properties', value: '${agent.propertiesVerified}')),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  Expanded(child: _AgentStat(label: 'Tenants', value: '${agent.tenantsReferred}')),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  Expanded(child: _AgentStat(label: 'Rating', value: '${agent.rating} ⭐')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: agent.areasServed.map((area) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(area, style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            _requested
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Service Request Sent', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _sendRequest(context),
                    icon: const Icon(Icons.handshake, size: 18),
                    label: const Text('Request Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _sendRequest(BuildContext context) {
    final agreement = AgentServiceAgreement(
      id: 'agr_${DateTime.now().millisecondsSinceEpoch}',
      landlordId: widget.landlordId,
      landlordName: widget.landlordName,
      agentId: widget.agent.agentId,
      agentName: widget.agent.name,
      status: 'Pending',
      requestedAt: DateTime.now(),
      serviceTerms: 'Standard property management and tenant referral services in ${widget.agent.areasServed.join(", ")}.',
    );
    // API integration would go here
    // ref.read(agentAgreementsProvider.notifier).requestAgreement(agreement);
    setState(() => _requested = true);
    context.showSuccessToast('Service request sent to ${widget.agent.name}!');
  }
}

class _AgentStat extends StatelessWidget {
  final String label;
  final String value;

  const _AgentStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
