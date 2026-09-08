import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../providers/domain_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
            ),
          ),
        ),
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
        error: (error, _) => Center(child: Text('Unable to load reports: $error')),
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
                  _kpiCard('Total Revenue', CurrencyFormatter.formatCFA(summary.totalRevenueXaf.toDouble()), Icons.payments, Colors.green),
                  _kpiCard('Properties', '${summary.totalProperties}', Icons.apartment, theme.colorScheme.primary),
                  _kpiCard('Users', '${summary.totalUsers}', Icons.people, Colors.blue),
                  _kpiCard('Applications', '${summary.totalApplications}', Icons.assignment, Colors.orange),
                  _kpiCard('Leases', '${summary.totalLeases}', Icons.description, Colors.indigo),
                  _kpiCard('Rentals', '${summary.totalRentals}', Icons.home_work, Colors.teal),
                ],
              ),
              const SizedBox(height: 28),
              _sectionTitle('User Breakdown'),
              const SizedBox(height: 12),
              ...summary.usersByRole.entries.map(
                (entry) => _dataRow(entry.key, '${entry.value} users'),
              ),
              _dataRow('Active subscriptions', '${summary.activeSubscriptions}'),
              _dataRow('Pending KYC', '${summary.pendingKyc}'),
              const SizedBox(height: 28),
              _sectionTitle('Live Totals'),
              const SizedBox(height: 12),
              _dataRow('Total users', '${summary.totalUsers}'),
              _dataRow('Total properties', '${summary.totalProperties}'),
              _dataRow('Total leases', '${summary.totalLeases}'),
              _dataRow('Total rentals', '${summary.totalRentals}'),
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

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
