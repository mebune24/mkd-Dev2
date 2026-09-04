import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../../providers/auth_provider.dart';

class MyAgentsScreen extends ConsumerWidget {
  const MyAgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final allAgreementsAsync = ref.watch(agentAgreementsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('My Agents', style: TextStyle(fontWeight: FontWeight.bold)),
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
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Find Agents',
            onPressed: () => context.push('/landlord/agents/marketplace'),
          ),
        ],
      ),
      body: allAgreementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allAgreements) {
          final myAgreements = allAgreements.where((a) => a.landlordId == (user.session?.userId ?? '')).toList();
          return myAgreements.isEmpty
              ? _EmptyAgentsState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (myAgreements.any((a) => a.status == 'Active')) ...[
                      const _SectionLabel(label: 'ACTIVE AGREEMENTS'),
                      ...myAgreements.where((a) => a.status == 'Active').map((a) => _AgreementCard(agreement: a)),
                    ],
                    if (myAgreements.any((a) => a.status == 'Pending' || a.status == 'Accepted')) ...[
                      const _SectionLabel(label: 'PENDING'),
                      ...myAgreements.where((a) => a.status == 'Pending' || a.status == 'Accepted').map((a) => _AgreementCard(agreement: a)),
                    ],
                    if (myAgreements.any((a) => a.status == 'Terminated')) ...[
                      const _SectionLabel(label: 'ENDED'),
                      ...myAgreements.where((a) => a.status == 'Terminated').map((a) => _AgreementCard(agreement: a)),
                    ],
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/landlord/agents/marketplace'),
        icon: const Icon(Icons.person_search),
        label: const Text('Find Agents'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _EmptyAgentsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.real_estate_agent, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            const Text('No Agents Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Hire a verified SpaceRentals Agent to help manage your properties and bring in qualified tenants.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.push('/landlord/agents/marketplace'),
              icon: const Icon(Icons.search),
              label: const Text('Browse Agent Directory'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
    );
  }
}

class _AgreementCard extends ConsumerWidget {
  final AgentServiceAgreement agreement;
  const _AgreementCard({required this.agreement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;
    switch (agreement.status) {
      case 'Active':
        statusColor = Colors.green; statusIcon = Icons.check_circle; break;
      case 'Pending':
        statusColor = Colors.orange; statusIcon = Icons.hourglass_empty; break;
      case 'Accepted':
        statusColor = Colors.blue; statusIcon = Icons.thumb_up; break;
      case 'Terminated':
        statusColor = Colors.red; statusIcon = Icons.cancel; break;
      default:
        statusColor = Colors.grey; statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.real_estate_agent, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agreement.agentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(agreement.agentId, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 3),
                      Text(agreement.status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            if (agreement.status == 'Pending') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 13, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Waiting for agent to accept your request.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  TextButton(
                    onPressed: () {}, // To be implemented
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
            if (agreement.status == 'Active') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () {}, // To be implemented
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                    label: const Text('Terminate', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
