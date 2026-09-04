import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/domain_providers.dart';
import '../../features/agents/domain/agent_models.dart';
import '../../core/utils/ui_helpers.dart';
import '../../providers/auth_provider.dart';

class AgentMarketplaceScreen extends ConsumerStatefulWidget {
  const AgentMarketplaceScreen({super.key});

  @override
  ConsumerState<AgentMarketplaceScreen> createState() => _AgentMarketplaceScreenState();
}

class _AgentMarketplaceScreenState extends ConsumerState<AgentMarketplaceScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agentsAsync = ref.watch(agentProfilesProvider);
    final auth = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Marketplace'),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search agents by name or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: agentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (agents) {
                // Filter to active agents and search query
                final activeAgents = agents.where((a) => a.status == 'active' && !a.isWalletFrozen).toList();
                final filtered = activeAgents.where((a) => 
                  a.name.toLowerCase().contains(_searchQuery) ||
                  a.location.toLowerCase().contains(_searchQuery) ||
                  a.areasServed.any((area) => area.toLowerCase().contains(_searchQuery))
                ).toList();

                // Sort by tier (Platinum first, then Gold, etc.) and rating
                filtered.sort((a, b) {
                  final tierComp = b.tier.index.compareTo(a.tier.index);
                  if (tierComp != 0) return tierComp;
                  return b.rating.compareTo(a.rating);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text('No agents found matching your criteria.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final agent = filtered[index];
                    return _AgentCard(agent: agent, currentUserId: auth.session?.userId ?? '');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends ConsumerWidget {
  final AgentProfile agent;
  final String currentUserId;

  const _AgentCard({required this.agent, required this.currentUserId});

  void _requestService(BuildContext context, WidgetRef ref) {
    // Generate a new service agreement
    final agreement = AgentServiceAgreement(
      id: 'agreement_${DateTime.now().millisecondsSinceEpoch}',
      landlordId: currentUserId,
      landlordName: 'Landlord User', // Mocked, ideally from user profile
      agentId: agent.agentId,
      agentName: agent.name,
      status: 'Pending',
      requestedAt: DateTime.now(),
      serviceTerms: 'Standard property verification and tenant referral services.',
    );
    
    // MVP: Fake request process, actual backend integration pending.
    // ref.read(agentAgreementsProvider.notifier).requestAgreement(agreement);
    
    context.showSuccessToast('Service Request sent to ${agent.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    agent.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: agent.tier.gradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(agent.tier.icon, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(agent.tier.label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(agent.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(width: 12),
                          Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(agent.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Areas Served', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: agent.areasServed.map((area) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                child: Text(area, style: const TextStyle(fontSize: 12)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verified Properties', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    Text('${agent.propertiesVerified}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tenants Referred', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    Text('${agent.tenantsReferred}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _requestService(context, ref),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hire Agent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
