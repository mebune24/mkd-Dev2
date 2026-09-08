import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../features/admin/domain/admin_transaction.dart';
import '../../providers/domain_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: () => ref.invalidate(adminReportsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load reports: $error')),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.refresh(adminReportsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
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
                  _kpiCard(
                    'Total Revenue',
                    CurrencyFormatter.formatCFA(
                      summary.totalRevenueXaf.toDouble(),
                    ),
                    Icons.payments,
                    Colors.green,
                  ),
                  _kpiCard(
                    'Active Listings',
                    '${summary.activeListings}',
                    Icons.apartment,
                    Colors.indigo,
                  ),
                  _kpiCard(
                    'Active Tenants',
                    '${summary.usersByRole['tenant'] ?? 0}',
                    Icons.people,
                    Colors.blue,
                  ),
                  _kpiCard(
                    'Active Leases',
                    '${summary.totalLeases}',
                    Icons.description,
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _sectionTitle('Monthly Revenue'),
              const SizedBox(height: 12),
              _RevenueChart(points: summary.monthlyRevenue),
              const SizedBox(height: 28),
              _sectionTitle('Active Listings by Category'),
              const SizedBox(height: 12),
              _CategoryChart(items: summary.listingsByCategory),
              const SizedBox(height: 28),
              _sectionTitle('Compliance Summary'),
              const SizedBox(height: 12),
              _complianceRow(
                'Digital leases signed',
                '${summary.compliance.signedLeases} / ${summary.compliance.totalLeases}',
                Icons.description,
                Colors.green,
                summary.compliance.signedLeases >=
                    summary.compliance.totalLeases,
              ),
              _complianceRow(
                'Successful payments',
                '${summary.compliance.successfulPayments}',
                Icons.payment,
                Colors.teal,
                true,
              ),
              _complianceRow(
                'Audit logs generated',
                '${summary.compliance.auditLogs}',
                Icons.history,
                Colors.indigo,
                true,
              ),
              _complianceRow(
                'Unresolved disputes',
                '${summary.compliance.unresolvedDisputes}',
                Icons.gavel,
                Colors.red,
                summary.compliance.unresolvedDisputes == 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
  );

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _complianceRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool passing,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 8),
          Icon(
            passing ? Icons.check_circle : Icons.warning_rounded,
            color: passing ? Colors.green : Colors.orange,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<RevenuePoint> points;
  const _RevenueChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyReportData(message: 'No revenue data available.');
    }
    final maxAmount = points
        .map((point) => point.amount)
        .fold<int>(0, (max, amount) => amount > max ? amount : max);
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: points.map((point) {
          final height = maxAmount == 0 ? 0.0 : 130 * point.amount / maxAmount;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCFA(
                  point.amount.toDouble(),
                ).replaceAll(' CFA', ''),
                style: const TextStyle(fontSize: 9, color: Colors.indigo),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height,
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                point.month,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<CategoryCount> items;
  const _CategoryChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyReportData(
        message: 'No active listing data available.',
      );
    }
    final total = items.fold<int>(0, (sum, item) => sum + item.count);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: items.map((item) {
          final ratio = total == 0 ? 0.0 : item.count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.category),
                    Text(
                      '${item.count} listings (${(ratio * 100).round()}%)',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  color: Colors.teal,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyReportData extends StatelessWidget {
  final String message;
  const _EmptyReportData({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(message, style: const TextStyle(color: Colors.grey)),
  );
}
