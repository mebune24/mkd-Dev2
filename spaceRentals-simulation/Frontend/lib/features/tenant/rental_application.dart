import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/properties/domain/property.dart';
import '../../features/applications/domain/application.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/money.dart';
import '../../providers/applications_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_loading_button.dart';
import '../../widgets/form_safe_modal.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/utils/ui_helpers.dart';

class RentalApplication extends ConsumerStatefulWidget {
  final PropertyWithListing property;

  const RentalApplication({super.key, required this.property});

  @override
  ConsumerState<RentalApplication> createState() => _RentalApplicationState();
}

class _RentalApplicationState extends ConsumerState<RentalApplication> {
  final _coverLetterCtrl = TextEditingController();
  final Map<String, bool> _uploadedDocs = {
    'National ID / Passport': false,
    'Proof of Income (Pay Slip)': false,
    'Employment Letter / Reference': false,
    'Recent Utility Bill': false,
  };
  
  String? _nationalIdUrl;
  String? _proofOfIncomeUrl;

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property.property;
    final submitAsync = ref.watch(applicationSubmitProvider);
    final theme = Theme.of(context);

    final hasChanges = _coverLetterCtrl.text.isNotEmpty ||
        _uploadedDocs.values.any((v) => v);

    return FormSafeModal(
      hasUnsavedChanges: hasChanges,
      discardTitle: 'Abandon Application?',
      discardMessage: 'You have started filling out this application. Are you sure you want to leave? Your progress will be lost.',
      child: Scaffold(
        appBar: AppBar(title: const Text('Rental Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('You are applying for:', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.house),
                title: Text(p.title),
                subtitle: Text(p.location),
              ),
            ),
            const SizedBox(height: 32),
            Text('Financial Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSummaryRow('Monthly Rent', CurrencyFormatter.formatCFA(p.monthlyRentUnits.toDouble()),
              note: 'Paid directly to your landlord — not collected by Space Rentals'),
            const SizedBox(height: 8),
            _buildSummaryRow('Required Deposit', CurrencyFormatter.formatCFA(p.depositUnits.toDouble()),
              note: 'Held by landlord'),
            const Divider(height: 24),
            // Platform fee — this is what Space Rentals actually charges the tenant
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Space Rentals Platform Fee',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Application Processing Fee', style: TextStyle(fontSize: 14)),
                      Text(SpaceFees.tenantApplicationFee.formatted(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This one-time fee is paid to Space Rentals for processing your application. It is non-refundable.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text('Cover Letter (Optional)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _coverLetterCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Introduce yourself and explain why you would be a great tenant...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Required Documents', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Upload supporting documents to complete your application:',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._uploadedDocs.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: entry.value
                      ? Colors.green.withValues(alpha: 0.06)
                      : Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: entry.value
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.upload_file,
                      color: entry.value ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            entry.value ? 'Uploaded ✓' : 'Tap to upload',
                            style: TextStyle(
                              fontSize: 11,
                              color: entry.value ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: entry.value
                          ? null
                          : () {
                              setState(() {
                                _uploadedDocs[entry.key] = true;
                                if (entry.key == 'National ID / Passport') {
                                  _nationalIdUrl = 'https://storage.spacerentals.cm/docs/${DateTime.now().millisecondsSinceEpoch}_national_id.jpg';
                                } else if (entry.key == 'Proof of Income (Pay Slip)') {
                                  _proofOfIncomeUrl = 'https://storage.spacerentals.cm/docs/${DateTime.now().millisecondsSinceEpoch}_proof_of_income.jpg';
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: entry.value ? Colors.green : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: Text(entry.value ? 'Done' : 'Upload'),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // Error banner
            if (submitAsync is AsyncError)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Submission failed. Please try again.',
                  style: TextStyle(color: Colors.red[700], fontSize: 13),
                ),
              ),

            AnimatedLoadingButton(
              onPressed: () async {
                final user = ref.read(authProvider);
                final request = SubmitApplicationRequest(
                  propertyId: p.id,
                  landlordId: p.landlordId,
                  coverLetter: _coverLetterCtrl.text.trim().isEmpty
                      ? null
                      : _coverLetterCtrl.text.trim(),
                  nationalIdUrl: _nationalIdUrl,
                  proofOfIncomeUrl: _proofOfIncomeUrl,
                );

                final ok = await ref
                    .read(applicationSubmitProvider.notifier)
                    .submitApplication(request);

                if (!mounted) return;

                if (ok) {
                  context.showAppDialog(builder: (context) => AlertDialog(
                      title: const Text('Application Submitted'),
                      content: const Text(
                          'The landlord will review your application. You can track the status in your dashboard.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                            context.go('/tenant');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
      ),
    ); // FormSafeModal
  }

  Widget _buildSummaryRow(String label, String amount,
      {bool isTotal = false, BuildContext? context, String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal && context != null ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ],
        ),
        if (note != null) ...[
          const SizedBox(height: 3),
          Text(note, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ],
    );
  }
}
