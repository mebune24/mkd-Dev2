import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/domain_providers.dart';
import '../../../features/landlord/domain/kyc_submission.dart';
import '../../../core/utils/ui_helpers.dart';

class AdminKYCManagementScreen extends ConsumerWidget {
  const AdminKYCManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submissionsAsync = ref.watch(kycSubmissionsProvider);

    return submissionsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error loading KYC: $err'))),
      data: (submissions) {
        final pending = submissions.where((s) => s.status == 'pending').toList();
        final approved = submissions.where((s) => s.status == 'approved' || s.status == 'verified').toList();
        final rejected = submissions.where((s) => s.status == 'rejected').toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('KYC Management',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              centerTitle: true,
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Approved (${approved.length})'),
                  Tab(text: 'Rejected (${rejected.length})'),
                ],
              ),
            ),
            backgroundColor: const Color(0xFFF3F0F7),
            body: TabBarView(
              children: [
                _SubmissionList(submissions: pending, canDecide: true),
                _SubmissionList(submissions: approved, canDecide: false),
                _SubmissionList(submissions: rejected, canDecide: false),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubmissionList extends StatelessWidget {
  final List<KYCSubmission> submissions;
  final bool canDecide;

  const _SubmissionList({required this.submissions, required this.canDecide});

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              canDecide ? 'No pending requests' : 'Nothing here yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        return _KYCCard(submission: submissions[index], canDecide: canDecide);
      },
    );
  }
}

class _KYCCard extends ConsumerStatefulWidget {
  final KYCSubmission submission;
  final bool canDecide;

  const _KYCCard({required this.submission, required this.canDecide});

  @override
  ConsumerState<_KYCCard> createState() => _KYCCardState();
}

class _KYCCardState extends ConsumerState<_KYCCard> {
  bool _isLoading = false;

  Future<void> _handleDecision(bool approve) async {
    setState(() => _isLoading = true);
    try {
      if (approve) {
        // 1. Update KYC status in the provider
        // ref.read(kycSubmissionsProvider.notifier).verifySubmission(widget.submission.userId);
        // 2. Log the audit
        // ref.read(auditLogProvider.notifier).addAudit(
        //   'admin',
        //   'admin',
        //   'Approved KYC for ${widget.submission.userName} (${widget.submission.userEmail})',
        // );
        // 3. Add a notification for the agent
        // ref.read(appNotificationsProvider.notifier).addNotification(
        //   userId: widget.submission.userId,
        //   title: '🎉 Agent Account Activated!',
        //   body: 'Your KYC documents have been approved. You can now access your Agent Dashboard and start earning.',
        //   type: 'kyc_approved',
        // );
        if (mounted) context.showSuccessToast('✅ ${widget.submission.userName} has been approved!');
      } else {
        // ref.read(kycSubmissionsProvider.notifier).rejectSubmission(widget.submission.userId);
        // ref.read(auditLogProvider.notifier).addAudit(
        //   'admin',
        //   'admin',
        //   'Rejected KYC for ${widget.submission.userName} (${widget.submission.userEmail})',
        // );
        // ref.read(appNotificationsProvider.notifier).addNotification(
        //   userId: widget.submission.userId,
        //   title: '❌ KYC Application Rejected',
        //   body: 'Your documents were not approved. Please resubmit with clear, valid documents.',
        //   type: 'kyc_rejected',
        // );
        if (mounted) context.showErrorToast('❌ ${widget.submission.userName} rejected.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.submission;
    final theme = Theme.of(context);
    final statusColor = sub.status == 'pending'
        ? Colors.orange
        : (sub.status == 'approved' || sub.status == 'verified')
            ? Colors.green
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    sub.userName.isNotEmpty ? sub.userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(sub.userEmail,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sub.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

            // Documents
            if (sub.documents.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Documents:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: sub.documents.entries
                    .map((e) => Chip(
                          label: Text(e.key, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.grey.shade100,
                          avatar: const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          padding: const EdgeInsets.all(4),
                        ))
                    .toList(),
              ),
            ],

            // Action Buttons (only for pending)
            if (widget.canDecide) ...[
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDecision(false),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleDecision(true),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
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
