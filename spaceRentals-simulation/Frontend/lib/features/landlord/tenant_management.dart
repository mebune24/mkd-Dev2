import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/applications_provider.dart';
import '../../features/applications/domain/application.dart';
import '../../shared/models/enums.dart';
import '../../providers/audit_log_provider.dart';

class TenantManagementScreen extends ConsumerWidget {
  const TenantManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(landlordApplicationsProvider).value ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications & Tenants'),
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
      body: applications.isEmpty
          ? const Center(child: Text('No applications yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, i) {
                return _ApplicationCard(app: applications[i]);
              },
            ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final Application app;
  const _ApplicationCard({required this.app});

  Color _statusColor() {
    switch (app.status) {
      case ApplicationStatus.draft: return Colors.grey;
      case ApplicationStatus.submitted: return Colors.orange;
      case ApplicationStatus.underReview: return Colors.orangeAccent;
      case ApplicationStatus.approved: return Colors.green;
      case ApplicationStatus.rejected: return Colors.red;
      case ApplicationStatus.withdrawn: return Colors.grey;
      case ApplicationStatus.expired: return Colors.blueGrey;
    }
  }

  String _statusLabel() {
    switch (app.status) {
      case ApplicationStatus.draft: return 'Draft';
      case ApplicationStatus.submitted: return 'Pending';
      case ApplicationStatus.underReview: return 'Under Review';
      case ApplicationStatus.approved: return 'Approved';
      case ApplicationStatus.rejected: return 'Rejected';
      case ApplicationStatus.withdrawn: return 'Withdrawn';
      case ApplicationStatus.expired: return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    app.tenantName.substring(0, 1),
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Applied for: ${app.propertyTitle}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(_statusLabel(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted: ${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (app.status == ApplicationStatus.submitted) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(applicationReviewProvider.notifier).approveApplication(app.id);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(applicationReviewProvider.notifier).rejectApplication(app.id);
                      },
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ] else if (app.status == ApplicationStatus.approved) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.description, size: 16),
                label: const Text('Generate Lease Document'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
              ),
            ] else if (app.status == ApplicationStatus.approved) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.edit_document, size: 16),
                label: const Text('Sign Lease Agreement'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
              ),
            ] else if (app.status == ApplicationStatus.approved) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.payments, size: 16),
                label: const Text('Confirm Payment Received'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
              ),
            ] else if (app.status == ApplicationStatus.approved) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.home, size: 16),
                label: const Text('Activate Rental'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(app.status == ApplicationStatus.approved ? Icons.check_circle : Icons.cancel, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    app.status == ApplicationStatus.approved
                        ? 'Rental is active'
                        : 'Application rejected',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
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
