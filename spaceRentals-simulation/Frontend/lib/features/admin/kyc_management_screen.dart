import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/domain_providers.dart';
import '../../../features/landlord/domain/kyc_submission.dart';
import '../../core/utils/ui_helpers.dart';
import '../../../core/utils/ui_helpers.dart';

class AdminKYCManagementScreen extends ConsumerWidget {
  const AdminKYCManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submissions = ref.watch(kycSubmissionsProvider);
    final pending = submissions.where((s) => s.status == 'pending').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Approvals'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F0F7),
      body: pending.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No pending KYC requests',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(kycSubmissionsProvider),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final sub = pending[index];
                return _KYCCard(submission: sub);
              },
            ),
    );
  }
}

class _KYCCard extends ConsumerStatefulWidget {
  final KYCSubmission submission;
  const _KYCCard({required this.submission});

  @override
  ConsumerState<_KYCCard> createState() => _KYCCardState();
}

class _KYCCardState extends ConsumerState<_KYCCard> {
  bool _isLoading = false;

  Future<void> _handleDecision(bool approve) async {
    setState(() => _isLoading = true);
    try {
      if (approve) {
        ref.read(kycSubmissionsProvider.notifier).approve(widget.submission.userId);
        ref.read(auditLogProvider.notifier).addAudit(
          'admin',
          'admin',
          'Approved KYC for user ${widget.submission.userId} (${widget.submission.userName})',
        );
      } else {
        ref.read(kycSubmissionsProvider.notifier).reject(widget.submission.userId);
        ref.read(auditLogProvider.notifier).addAudit(
          'admin',
          'admin',
          'Rejected KYC for user ${widget.submission.userId} (${widget.submission.userName})',
        );
      }
      if (mounted) {
        if (approve) {
          context.showSuccessToast('KYC approved for \${widget.submission.userName}');
        } else {
          context.showErrorToast('KYC rejected for \${widget.submission.userName}');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.submission;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(sub.userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sub.isPremium
                        ? Colors.amber.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sub.isPremium ? 'Premium' : 'Basic',
                    style: TextStyle(
                      color: sub.isPremium
                          ? Colors.amber.shade900
                          : Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(sub.userEmail,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (sub.documents.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Submitted Documents:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sub.documents.entries
                    .map((e) => Chip(
                          label: Text(e.key, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.grey.shade100,
                          avatar: const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDecision(false),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleDecision(true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
