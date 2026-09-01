import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payments_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/api/api_payment_repository.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/ui_helpers.dart';
import 'package:intl/intl.dart';

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
    
    final allAsync = ref.watch(myTransactionsProvider);
    final pendingAsync = ref.watch(pendingTransactionsProvider);
    final successfulAsync = ref.watch(successfulTransactionsProvider);
    final totalRevenueAsync = ref.watch(totalRevenueProvider);

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
                            Expanded(child: _buildHeaderStat('Total Revenue', totalRevenueAsync.when(data: (d) => CurrencyFormatter.formatCFA(d as double), loading: () => '...', error: (_,__) => 'Err'), Icons.account_balance_wallet, Colors.greenAccent)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildHeaderStat('Pending', pendingAsync.when(data: (l) => '${l.length}', loading: () => '...', error: (_,__) => 'Err'), Icons.pending_actions, Colors.orangeAccent)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildHeaderStat('Approved', successfulAsync.when(data: (l) => '${l.length}', loading: () => '...', error: (_,__) => 'Err'), Icons.check_circle_outline, Colors.lightGreenAccent)),
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
        body: allAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: \$e')),
          data: (all) {
            final pending = all.where((t) => t.status == 'PENDING').toList();
            final history = all.where((t) => t.status != 'PENDING').toList();
            final rev = totalRevenueAsync.value ?? 0.0;
            return TabBarView(
              controller: _tabController,
              children: [
                _PendingTab(transactions: pending),
                _HistoryTab(transactions: history),
                _LedgerTab(transactions: all, totalRevenue: rev),
              ],
            );
          }
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
  final List<TransactionRecord> transactions;
  const _PendingTab({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
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
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionCard(
          tx: tx,
          showActions: false, 
        );
      },
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final List<TransactionRecord> transactions;
  const _HistoryTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No payment history yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) => _TransactionCard(tx: transactions[index], showActions: false),
    );
  }
}

// ── Ledger Tab ────────────────────────────────────────────────────────────────
class _LedgerTab extends StatelessWidget {
  final List<TransactionRecord> transactions;
  final double totalRevenue;
  const _LedgerTab({required this.transactions, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Map<String, List<TransactionRecord>> byMonth = {};
    for (final t in transactions) {
      final month = DateFormat('MMMM yyyy').format(t.createdAt);
      byMonth.putIfAbsent(month, () => []).add(t);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    _ledgerBadge("${transactions.where((p) => p.status == 'SUCCESSFUL').length} Approved", Colors.greenAccent),
                    const SizedBox(width: 8),
                    _ledgerBadge("${transactions.where((p) => p.status == 'PENDING').length} Pending", Colors.orangeAccent),
                    const SizedBox(width: 8),
                    _ledgerBadge("${transactions.where((p) => p.status == 'FAILED').length} Failed", Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...months.map((month) {
            final monthTxs = byMonth[month]!;
            final monthTotal = monthTxs.where((p) => p.status == 'SUCCESSFUL').fold(0.0, (s, p) => s + p.amount);
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
                ...monthTxs.map((t) => _LedgerRow(tx: t)),
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
  final TransactionRecord tx;
  const _LedgerRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    Color statusColor = tx.status == 'SUCCESSFUL' ? Colors.green : tx.status == 'PENDING' ? Colors.orange : Colors.red;
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
                Text(tx.transactionType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(DateFormat('MMM dd, yyyy').format(tx.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.formatCFA(tx.amount.toDouble()), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(tx.status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionRecord tx;
  final bool showActions;

  const _TransactionCard({required this.tx, required this.showActions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = tx.status == 'SUCCESSFUL' ? Colors.green : tx.status == 'PENDING' ? Colors.orange : Colors.red;
    final typeIcon = Icons.payments;

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
                      Text(tx.transactionType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM dd, yyyy HH:mm').format(tx.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(tx.paymentMethod, style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.formatCFA(tx.amount.toDouble()), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: statusColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(tx.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
