import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/money.dart';
import '../../providers/applications_provider.dart';
import '../../providers/domain_providers.dart';
import '../../shared/models/enums.dart';
import '../../widgets/empty_state.dart';

class PaymentsScreen extends ConsumerWidget {
  final String tenantId;
  const PaymentsScreen({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applicationsAsync = ref.watch(tenantApplicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Payments & Fees'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Failed to load payments: $e', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(tenantApplicationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (applications) {
          final submitted = applications
              .where((a) => a.status != ApplicationStatus.draft && a.status != ApplicationStatus.withdrawn)
              .toList();
          final feesPaid = submitted.length * SpaceFees.tenantApplicationFee.minorUnits;

          return ListView(
            padding: const EdgeInsets.all(0),
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Platform Fees Paid',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      Money(feesPaid).formatted(),
                      style: theme.textTheme.displaySmall
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${submitted.length} application${submitted.length == 1 ? '' : 's'} submitted',
                        style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── How Payments Work ────────────────────────────────────────────
              _SectionHeader(title: 'How Payments Work'),
              _InfoCard(
                icon: Icons.home_work_outlined,
                iconColor: const Color(0xFF7B2FBE),
                title: 'Rent → Directly to Your Landlord',
                body:
                    'Space Rentals does NOT collect your monthly rent. You pay your landlord directly via the method agreed in your lease (mobile money, bank transfer, etc.).',
              ),
              _InfoCard(
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.orange,
                title: 'Application Fee → Space Rentals',
                body:
                    '${SpaceFees.tenantApplicationFee.formatted()} per application is paid to Space Rentals for processing and verifying your rental application. This is non-refundable.',
              ),

              const SizedBox(height: 8),

              // ── Application Fees History ─────────────────────────────────────
              _SectionHeader(title: 'Application Fee History'),
              if (submitted.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: EmptyState(
                    title: 'No Fees Yet',
                    message: 'No application fees yet. Submit a rental application to get started.',
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              else
                ...submitted.map((app) => _FeeHistoryTile(
                      title: app.propertyTitle,
                      amount: SpaceFees.tenantApplicationFee,
                      status: app.status,
                      date: app.submittedAt,
                    )),

              const SizedBox(height: 24),

              // ── Rent Payments Info ───────────────────────────────────────────
              _SectionHeader(title: 'Your Active Rentals'),
              const _InfoCard(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                title: 'Pay Rent via Your Lease Agreement',
                body:
                    'Once your lease is signed, your landlord will share payment instructions. Use the messaging feature to coordinate rent collection. Space Rentals keeps a verified record but does not handle the funds.',
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeHistoryTile extends StatelessWidget {
  final String title;
  final Money amount;
  final ApplicationStatus status;
  final DateTime date;

  const _FeeHistoryTile({
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });

  Color get _statusColor {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.underReview:
        return Colors.orange;
      case ApplicationStatus.submitted:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (status) {
      case ApplicationStatus.approved:
        return 'APPROVED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
      case ApplicationStatus.underReview:
        return 'UNDER REVIEW';
      case ApplicationStatus.submitted:
        return 'SUBMITTED';
      default:
        return status.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  'Application Fee • ${date.day}/${date.month}/${date.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount.formatted(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                      fontSize: 10, color: _statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
