import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock analytics data
    final monthlyRevenue = [
      {'month': 'Apr', 'amount': 1200000.0},
      {'month': 'May', 'amount': 1750000.0},
      {'month': 'Jun', 'amount': 1500000.0},
      {'month': 'Jul', 'amount': 2100000.0},
      {'month': 'Aug', 'amount': 1900000.0},
    ];
    final totalRevenue = monthlyRevenue.fold<double>(0, (s, m) => s + (m['amount'] as double));
    final maxRevenue = monthlyRevenue.map((m) => m['amount'] as double).reduce((a, b) => a > b ? a : b);

    final categoryBreakdown = [
      {'label': 'Apartments', 'count': 5, 'color': const Color(0xFF6A1B9A)},
      {'label': 'Studios', 'count': 3, 'color': Colors.teal},
      {'label': 'Villas', 'count': 2, 'color': Colors.orange},
      {'label': 'Commercial', 'count': 1, 'color': Colors.indigo},
    ];
    final totalListings = categoryBreakdown.fold<int>(0, (s, c) => s + (c['count'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI Cards ───────────────────────────────────────────────────
            _sectionTitle('Platform KPIs'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _kpiCard(context, 'Total Revenue', CurrencyFormatter.formatCFA(totalRevenue), Icons.payments, Colors.green),
                _kpiCard(context, 'Active Listings', '$totalListings', Icons.apartment, theme.colorScheme.primary),
                _kpiCard(context, 'Occupancy Rate', '72%', Icons.door_front_door, Colors.teal),
                _kpiCard(context, 'Avg Rent (CFA)', '145,000', Icons.trending_up, Colors.orange),
                _kpiCard(context, 'Active Tenants', '8', Icons.people, Colors.blue),
                _kpiCard(context, 'Active Leases', '6', Icons.description, Colors.indigo),
              ],
            ),
            const SizedBox(height: 28),

            // ── Monthly Revenue Bar Chart ─────────────────────────────────
            _sectionTitle('Monthly Revenue (Last 5 Months)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: monthlyRevenue.map((m) {
                        final pct = (m['amount'] as double) / maxRevenue;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.formatCFA(m['amount'] as double).replaceAll(' CFA', ''),
                              style: TextStyle(fontSize: 9, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              width: 36,
                              height: 110 * pct,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(m['month'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Listings by Category ──────────────────────────────────────
            _sectionTitle('Active Listings by Category'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: categoryBreakdown.map((c) {
                  final pct = (c['count'] as int) / totalListings;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${c['count']} listings  (${(pct * 100).round()}%)',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(c['color'] as Color),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // ── Compliance Summary ────────────────────────────────────────
            _sectionTitle('Compliance Summary'),
            const SizedBox(height: 12),
            _complianceRow('Digital leases signed', '6 / 6', Icons.description, Colors.green, true),
            _complianceRow('Payments with MoMo/Orange', '18 / 20', Icons.payment, Colors.teal, true),
            _complianceRow('OHADA audit logs generated', '24', Icons.history, Colors.indigo, true),
            _complianceRow('Unresolved disputes', '2', Icons.gavel, Colors.red, false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      );

  Widget _kpiCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
          FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _complianceRow(String label, String value, IconData icon, Color color, bool passing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 8),
          Icon(passing ? Icons.check_circle : Icons.warning_rounded, color: passing ? Colors.green : Colors.orange, size: 18),
        ],
      ),
    );
  }
}
