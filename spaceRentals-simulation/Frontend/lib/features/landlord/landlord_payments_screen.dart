import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payments_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/ui_helpers.dart';

class LandlordPaymentsScreen extends ConsumerStatefulWidget {
  const LandlordPaymentsScreen({super.key});

  @override
  ConsumerState<LandlordPaymentsScreen> createState() => _LandlordPaymentsScreenState();
}

class _LandlordPaymentsScreenState extends ConsumerState<LandlordPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final landlordId = user.session?.userId ?? 'landlord_001';
    final allPayments = ref.watch(landlordPaymentsProvider(landlordId));
    final pending = ref.watch(pendingPaymentsProvider(landlordId));
    final approved = ref.watch(approvedPaymentsProvider(landlordId));
    final totalRevenue = ref.watch(totalRevenueProvider(landlordId));
    final rejected = allPayments.where((p) => p.status == 'rejected').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Payments', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildHeaderStat('Total Revenue', CurrencyFormatter.formatCFA(totalRevenue), Icons.account_balance_wallet, Colors.greenAccent)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildHeaderStat('Pending', '${pending.length}', Icons.pending_actions, Colors.orangeAccent)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildHeaderStat('Approved', '${approved.length}', Icons.check_circle_outline, Colors.lightGreenAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'History'),
                Tab(text: 'Ledger'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PendingTab(payments: pending),
            _HistoryTab(payments: [...approved, ...rejected]..sort((a, b) => b.createdAt.compareTo(a.createdAt))),
            _LedgerTab(payments: allPayments, totalRevenue: totalRevenue),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Pending Payments Tab ────────────────────────────────────────────────────────
class _PendingTab extends ConsumerWidget {
  final List<PaymentModel> payments;
  const _PendingTab({required this.payments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No Pending Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('All payments are up to date!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _PaymentCard(
          payment: payment,
          showActions: true,
          onApprove: () => _confirmApprove(context, ref, payment),
          onReject: () => _confirmReject(context, ref, payment),
        );
      },
    );
  }

  void _confirmApprove(BuildContext context, WidgetRef ref, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Approve Payment'),
          ],
        ),
        content: Text('Approve ${CurrencyFormatter.formatCFA(payment.amount)} from ${payment.tenantName} for ${payment.month}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              ref.read(paymentsProvider.notifier).approvePayment(payment.id);
              Navigator.pop(ctx);
              context.showSuccessToast('Payment approved ✓');
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, WidgetRef ref, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Reject Payment'),
          ],
        ),
        content: Text('Reject ${CurrencyFormatter.formatCFA(payment.amount)} from ${payment.tenantName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              ref.read(paymentsProvider.notifier).rejectPayment(payment.id);
              Navigator.pop(ctx);
              context.showErrorToast('Payment rejected');
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final List<PaymentModel> payments;
  const _HistoryTab({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Center(child: Text('No payment history yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) => _PaymentCard(payment: payments[index], showActions: false),
    );
  }
}

// ── Ledger Tab ────────────────────────────────────────────────────────────────
class _LedgerTab extends StatelessWidget {
  final List<PaymentModel> payments;
  final double totalRevenue;
  const _LedgerTab({required this.payments, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Group by month
    final Map<String, List<PaymentModel>> byMonth = {};
    for (final p in payments) {
      byMonth.putIfAbsent(p.month, () => []).add(p);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF2D6A4F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Approved Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(CurrencyFormatter.formatCFA(totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ledgerBadge('${payments.where((p) => p.status == 'approved').length} Approved', Colors.greenAccent),
                    const SizedBox(width: 8),
                    _ledgerBadge('${payments.where((p) => p.status == 'pending').length} Pending', Colors.orangeAccent),
                    const SizedBox(width: 8),
                    _ledgerBadge('${payments.where((p) => p.status == 'rejected').length} Rejected', Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...months.map((month) {
            final monthPayments = byMonth[month]!;
            final monthTotal = monthPayments.where((p) => p.status == 'approved').fold(0.0, (s, p) => s + p.amount);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(CurrencyFormatter.formatCFA(monthTotal), style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ...monthPayments.map((p) => _LedgerRow(payment: p)),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _ledgerBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final PaymentModel payment;
  const _LedgerRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    Color statusColor = payment.status == 'approved' ? Colors.green : payment.status == 'pending' ? Colors.orange : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
      child: Row(
        children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(payment.description, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.formatCFA(payment.amount), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(payment.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Payment Card ────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PaymentCard({required this.payment, required this.showActions, this.onApprove, this.onReject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = payment.status == 'approved' ? Colors.green : payment.status == 'pending' ? Colors.orange : Colors.red;
    final typeIcon = payment.type == 'rent' ? Icons.home : payment.type == 'deposit' ? Icons.lock : payment.type == 'maintenance' ? Icons.handyman : Icons.payments;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                  child: Icon(typeIcon, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payment.tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(payment.propertyTitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(payment.type.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          Text(payment.month, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.formatCFA(payment.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: statusColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(payment.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showActions && payment.status == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onApprove,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
