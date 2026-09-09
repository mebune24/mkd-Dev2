import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_admin_repository.dart';
import '../../providers/di_providers.dart';
import '../../providers/domain_providers.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/api/storage_service.dart';
import '../landlord/domain/kyc_submission.dart';

class AdminLandlordKycScreen extends ConsumerWidget {
  const AdminLandlordKycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(landlordKycSubmissionsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Landlord KYC'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: submissions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading landlord KYC: $error')),
        data: (items) {
          final pending = items
              .where((item) => item.status == 'pending')
              .toList();
          final approved = items
              .where((item) => item.status == 'approved')
              .toList();
          final rejected = items
              .where((item) => item.status == 'rejected')
              .toList();
          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  child: TabBar(
                    tabs: [
                      Tab(text: 'Pending (${pending.length})'),
                      Tab(text: 'Approved (${approved.length})'),
                      Tab(text: 'Rejected (${rejected.length})'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _LandlordKycList(
                        items: pending,
                        canDecide: true,
                        ref: ref,
                      ),
                      _LandlordKycList(
                        items: approved,
                        canDecide: false,
                        ref: ref,
                      ),
                      _LandlordKycList(
                        items: rejected,
                        canDecide: false,
                        ref: ref,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LandlordKycList extends StatelessWidget {
  final List<KYCSubmission> items;
  final bool canDecide;
  final WidgetRef ref;

  const _LandlordKycList({
    required this.items,
    required this.canDecide,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Nothing here yet.'));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _LandlordKycCard(
        submission: items[index],
        repository: ref.read(adminRepositoryProvider),
        canDecide: canDecide,
        onChanged: () => ref.invalidate(landlordKycSubmissionsProvider),
      ),
    );
  }
}

class _LandlordKycCard extends StatefulWidget {
  final KYCSubmission submission;
  final ApiAdminRepository repository;
  final bool canDecide;
  final VoidCallback onChanged;

  const _LandlordKycCard({
    required this.submission,
    required this.repository,
    required this.canDecide,
    required this.onChanged,
  });

  @override
  State<_LandlordKycCard> createState() => _LandlordKycCardState();
}

class _LandlordKycCardState extends State<_LandlordKycCard> {
  bool _loading = false;

  Future<void> _openDocument(String label, String path) async {
    try {
      final bytes = await StorageService.instance.downloadFile(
        path,
        'kyc-documents',
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(label),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Flexible(
                  child: InteractiveViewer(
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) context.showErrorToast(error.toString());
    }
  }

  Future<void> _decide(bool approve) async {
    setState(() => _loading = true);
    try {
      if (approve) {
        await widget.repository.approveLandlordKyc(widget.submission.id);
      } else {
        await widget.repository.rejectLandlordKyc(widget.submission.id);
      }
      widget.onChanged();
      if (mounted)
        context.showSuccessToast(
          approve ? 'Landlord KYC approved.' : 'Landlord KYC rejected.',
        );
    } catch (error) {
      if (mounted) context.showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.business_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.submission.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.submission.userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    widget.submission.isPremium ? 'PREMIUM' : 'BASIC',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Submitted: ${widget.submission.submittedAt.day}/${widget.submission.submittedAt.month}/${widget.submission.submittedAt.year}',
            ),
            if (widget.submission.documents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: widget.submission.documents.keys
                    .map(
                      (key) => ActionChip(
                        label: Text(key),
                        avatar: const Icon(Icons.visibility_outlined, size: 16),
                        onPressed: () => _openDocument(
                          key,
                          widget.submission.documents[key]!,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (widget.canDecide) ...[
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _decide(false),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _decide(true),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
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
