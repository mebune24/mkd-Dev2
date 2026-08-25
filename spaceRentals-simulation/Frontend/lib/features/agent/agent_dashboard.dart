import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import 'agent_properties_screen.dart';
import 'agent_clients_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/ui_helpers.dart';

class AgentDashboard extends ConsumerStatefulWidget {
  const AgentDashboard({super.key});

  @override
  ConsumerState<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends ConsumerState<AgentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _AgentOverview(),
    AgentPropertiesScreen(),
    AgentClientsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), activeIcon: Icon(Icons.home_work), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AgentOverview extends ConsumerWidget {
  const _AgentOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactions = ref.watch(agentTransactionsProvider);
    final agents = ref.watch(agentProfilesProvider);

    // Mock agent ID — will link to real auth user in production
    const mockAgentId = 'agt_sample_1';
    final agentProfile = agents.firstWhere((a) => a.agentId == mockAgentId, orElse: () => agents.first);
    final myTx = transactions.where((t) => t.agentId == mockAgentId).toList();
    final balance = myTx.where((t) => t.status == 'Approved').fold(0.0, (s, t) => s + t.amount);
    final pending = myTx.where((t) => t.status == 'Pending').fold(0.0, (s, t) => s + t.amount);
    final totalEarned = myTx.fold(0.0, (s, t) => s + t.amount);
    final propertyCommission = myTx.where((t) => t.type == 'Property Verification' && t.status == 'Approved').fold(0.0, (s, t) => s + t.amount);
    final tenantCommission = myTx.where((t) => t.type == 'Tenant Referral' && t.status == 'Approved').fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agent Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('ID: AGT-00231', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Balance Card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                        child: const Text('🟢 Active Agent', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(CurrencyFormatter.formatCFA(balance), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _BalanceStat(label: 'Pending (Lease)', value: CurrencyFormatter.formatCFA(pending), icon: Icons.hourglass_empty, iconColor: Colors.orangeAccent)),
                      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                      Expanded(child: _BalanceStat(label: 'Total Earned', value: CurrencyFormatter.formatCFA(totalEarned), icon: Icons.trending_up, iconColor: Colors.greenAccent)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: agentProfile.isWalletFrozen
                        ? () {
                            context.showErrorToast('Withdrawals are temporarily disabled for your account. Contact Admin.');
                          }
                        : () => _showWithdrawalSheet(context),
                    icon: Icon(agentProfile.isWalletFrozen ? Icons.lock : Icons.account_balance_wallet, size: 18),
                    label: Text(agentProfile.isWalletFrozen ? 'Wallet Frozen' : 'Withdraw via Mobile Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Referrals ────────────────────────────────────────────
            _SectionCard(
              title: 'Referrals',
              icon: Icons.group_add,
              color: Colors.orange,
              children: [
                const _StatRow(label: 'Tenants Referred', value: '43'),
                const _StatRow(label: 'Qualified Tenants', value: '38', valueColor: Colors.green),
                _StatRow(label: 'Tenant Commission', value: CurrencyFormatter.formatCFA(tenantCommission), valueColor: Colors.green, isBold: true),
              ],
            ),
            const SizedBox(height: 16),

            // ── Properties ───────────────────────────────────────────
            _SectionCard(
              title: 'Properties',
              icon: Icons.home_work,
              color: Colors.blue,
              children: [
                const Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'Submitted', value: '31', color: Colors.blue)),
                    Expanded(child: _MiniStat(label: 'Verified', value: '25', color: Colors.green)),
                    Expanded(child: _MiniStat(label: 'Rejected', value: '4', color: Colors.red)),
                    Expanded(child: _MiniStat(label: 'Pending', value: '2', color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 12),
                _StatRow(label: 'Property Commission', value: CurrencyFormatter.formatCFA(propertyCommission), valueColor: Colors.green, isBold: true),
              ],
            ),
            const SizedBox(height: 16),

            // ── Landlords ────────────────────────────────────────────
            const _SectionCard(
              title: 'Landlords',
              icon: Icons.handshake,
              color: Colors.teal,
              children: [
                _StatRow(label: 'Active Relationships', value: '4', valueColor: Colors.green),
                _StatRow(label: 'Pending Requests', value: '2', valueColor: Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent Transactions ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 8),
            ...myTx.take(3).map((tx) => _TransactionTile(tx: tx)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WithdrawalSheet(),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _BalanceStat({required this.label, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _StatRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: 14, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AgentTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final statusColor = tx.status == 'Approved' ? Colors.green
        : tx.status == 'Paid' ? Colors.blue
        : tx.status == 'Rejected' ? Colors.red
        : Colors.orange;
    final icon = tx.type == 'Property Verification' ? Icons.home_work
        : tx.type == 'Tenant Referral' ? Icons.person_add
        : Icons.account_balance_wallet;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(tx.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.type == 'Mobile Withdrawal' ? '- ${CurrencyFormatter.formatCFA(tx.amount)}' : '+ ${CurrencyFormatter.formatCFA(tx.amount)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tx.type == 'Mobile Withdrawal' ? Colors.red : Colors.green),
              ),
              Text('${tx.createdAt.day}/${tx.createdAt.month}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawalSheet extends StatefulWidget {
  const _WithdrawalSheet();

  @override
  State<_WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends State<_WithdrawalSheet> {
  String _selectedProvider = 'MTN MoMo';
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Withdraw Earnings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Funds will be sent within 24 hours.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            const Text('Select Provider', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: ['MTN MoMo', 'Orange Money'].map((provider) {
                final isSelected = _selectedProvider == provider;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedProvider = provider),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
                      ),
                      child: Text(provider, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : Colors.grey)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+237 6XX XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (FCFA)',
                hintText: 'Min. 1,000 FCFA',
                prefixIcon: const Icon(Icons.payments),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.showSuccessToast('Withdrawal request submitted! Funds arrive within 24h.');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Confirm Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
