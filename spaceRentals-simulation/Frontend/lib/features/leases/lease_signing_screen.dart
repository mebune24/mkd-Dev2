import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../features/leases/domain/lease.dart';
import '../../providers/lease_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/enums.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/api/api_endpoints.dart';
import '../../providers/di_providers.dart';
import '../../core/utils/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Provider: load a lease by its own ID ─────────────────────────────────────
final leaseByIdProvider = FutureProvider.family<Lease?, String>((ref, leaseId) async {
  final repo = ref.watch(leaseRepositoryProvider);
  try {
    return await repo.getLease(leaseId);
  } catch (_) {
    return null;
  }
});

// ── Provider: load a lease by applicationId (used from application cards) ────
final leaseByApplicationIdProvider = FutureProvider.family<Lease?, String>((ref, applicationId) async {
  final repo = ref.watch(leaseRepositoryProvider);
  try {
    return await repo.getLeaseByApplicationId(applicationId);
  } catch (_) {
    return null;
  }
});

// ── Screen ────────────────────────────────────────────────────────────────────
class LeaseSigningScreen extends ConsumerStatefulWidget {
  /// Pass either a leaseId directly, or the applicationId — we'll load by applicationId
  final String applicationId;
  const LeaseSigningScreen({super.key, required this.applicationId});

  @override
  ConsumerState<LeaseSigningScreen> createState() => _LeaseSigningScreenState();
}

class _LeaseSigningScreenState extends ConsumerState<LeaseSigningScreen> {
  bool _hasReadDocument = false;
  bool _isSigning = false;

  @override
  Widget build(BuildContext context) {
    final leaseAsync = ref.watch(leaseByApplicationIdProvider(widget.applicationId));
    final session = ref.watch(authProvider).session;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Lease Agreement'),
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
        elevation: 0,
      ),
      body: leaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(e.toString()),
        data: (lease) {
          if (lease == null) return _buildError('No lease found for this application yet.');
          return _buildContent(context, lease, session, theme);
        },
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.invalidate(leaseByApplicationIdProvider(widget.applicationId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Lease lease, dynamic session, ThemeData theme) {
    final myRole = session?.role ?? Role.tenant;
    final canSign = lease.needsSignatureFrom(myRole);
    final alreadySigned = myRole == Role.tenant
        ? lease.tenantSignature?.status == SignatureStatus.signed
        : lease.landlordSignature?.status == SignatureStatus.signed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status Banner ────────────────────────────────────────────
          _buildStatusBanner(lease, theme),
          const SizedBox(height: 20),

          // ── Lease Summary ────────────────────────────────────────────
          _buildSection('Lease Details', theme, [
            _detailRow('Lease ID', lease.id.substring(0, 8).toUpperCase()),
            _detailRow('Property', lease.propertyTitle),
            _detailRow('Status', _statusLabel(lease.status)),
            _detailRow('Created', _formatDate(lease.createdAt)),
          ]),
          const SizedBox(height: 16),

          // ── Signature Status ─────────────────────────────────────────
          _buildSignatureStatus(lease, theme),
          const SizedBox(height: 16),

          // ── OHADA Compliance Notice ─────────────────────────────────
          _buildOhadaNotice(theme),
          const SizedBox(height: 16),

          // ── Lease Document ───────────────────────────────────────────
          if (lease.leaseDocumentUrl != null) ...[
            _buildDocumentViewer(lease.leaseDocumentUrl!, theme),
            const SizedBox(height: 16),
          ],

          // ── Consent Checkbox ─────────────────────────────────────────
          if (canSign && !alreadySigned) ...[
            _buildConsentCheckbox(theme),
            const SizedBox(height: 20),
            _buildSignButton(lease, session, theme),
          ],

          // ── Already Signed ───────────────────────────────────────────
          if (alreadySigned) ...[
            _buildAlreadySignedBanner(lease, myRole, theme),
            const SizedBox(height: 16),
          ],

          // ── Fully Signed → Proceed to Payments ──────────────────────
          if (lease.isFullySigned) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _initiateLeasePayment(context, ref, lease, session),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Proceed to First Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────

  Widget _buildStatusBanner(Lease lease, ThemeData theme) {
    final (color, icon, label) = _statusDecor(lease.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lease Agreement', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (lease.isFullySigned)
            const Icon(Icons.verified, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildSection(String title, ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSignatureStatus(Lease lease, ThemeData theme) {
    return _buildSection('Signature Status', theme, [
      _signatureRow('Tenant Signature', lease.tenantSignature?.status, lease.tenantSignature?.signedAt, theme),
      const SizedBox(height: 10),
      _signatureRow('Landlord Signature', lease.landlordSignature?.status, lease.landlordSignature?.signedAt, theme),
    ]);
  }

  Widget _signatureRow(String label, SignatureStatus? status, DateTime? signedAt, ThemeData theme) {
    final signed = status == SignatureStatus.signed;
    final color = signed ? Colors.green : (status == SignatureStatus.declined ? Colors.red : Colors.orange);
    final icon = signed ? Icons.check_circle : (status == SignatureStatus.declined ? Icons.cancel : Icons.pending);
    final text = signed
        ? 'Signed${signedAt != null ? ' · ${_formatDate(signedAt)}' : ''}'
        : (status == SignatureStatus.declined ? 'Declined' : 'Awaiting signature');

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOhadaNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user, color: Colors.indigo, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This lease is electronically signed and time-stamped in compliance with OHADA Uniform Act on General Commercial Law and Cameroon Law No. 2010/021 on Electronic Commerce. '
              'All signature events are cryptographically hashed (SHA-256) and immutably recorded.',
              style: TextStyle(fontSize: 11, color: Colors.indigo, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer(String url, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lease Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {/* open in browser or PDF viewer */},
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View / Download Lease PDF'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _hasReadDocument,
            onChanged: (v) => setState(() => _hasReadDocument = v ?? false),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'I confirm that I have read and understood the full lease agreement and agree to be legally bound by its terms.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignButton(Lease lease, dynamic session, ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: (!_hasReadDocument || _isSigning)
          ? null
          : () => _signLease(lease, session),
      icon: _isSigning
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.draw),
      label: Text(_isSigning ? 'Signing…' : 'Sign Electronically'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildAlreadySignedBanner(Lease lease, Role myRole, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lease.isFullySigned
                  ? 'Both parties have signed. The lease is fully executed.'
                  : 'You have signed. Waiting for the other party to sign.',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign action ──────────────────────────────────────────────────────────
  Future<void> _signLease(Lease lease, dynamic session) async {
    setState(() => _isSigning = true);

    // Build SHA-256 signature hash (OHADA-aligned)
    final rawData = '${lease.id}|${session?.userId ?? ''}|${DateTime.now().toIso8601String()}';
    final signatureHash = sha256.convert(utf8.encode(rawData)).toString();

    // Also send audit log to backend before signing
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        '${ApiEndpoints.baseUrl}/api/audit-logs',
        data: {
          'action': 'lease.signed',
          'resourceId': lease.id,
          'resourceType': 'lease',
          'signatureHash': signatureHash,
          'metadata': {
            'role': session?.role.name,
            'propertyId': lease.propertyId,
          },
        },
      );
    } catch (_) {
      // Non-blocking — backend will also record on its side
    }

    final ok = await ref.read(leaseSignatureProvider.notifier).signLease(lease.id);

    if (mounted) {
      setState(() => _isSigning = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Lease signed electronically'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(leaseByApplicationIdProvider(widget.applicationId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signing failed. Please try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Payment Action ─────────────────────────────────────────────────────────
  Future<void> _initiateLeasePayment(BuildContext context, WidgetRef ref, Lease lease, dynamic session) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );

    try {
      // 1. Get the property to know the rent & deposit
      final propRepo = ref.read(propertyRepositoryProvider);
      final prop = await propRepo.getProperty(lease.propertyId);
      final totalAmount = prop.property.monthlyRentUnits + prop.property.depositUnits;

      // 2. Initiate Fapshi Payment
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final response = await paymentRepo.initiatePayment(
        amount: totalAmount,
        email: session?.email ?? 'tenant@example.com',
        message: 'Rent & Deposit for \${lease.propertyTitle}',
        referenceType: 'LEASE',
        referenceId: lease.id,
        paymentMethod: 'MOBILE_MONEY',
      );

      Navigator.pop(context); // Close loading dialog

      // 3. Launch Fapshi Link
      if (response.paymentLink != null) {
        final uri = Uri.parse(response.paymentLink!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          context.showErrorToast('Could not launch payment link');
        }
      } else {
        context.showSuccessToast('Payment initiated successfully');
      }
    } catch (e) {
      Navigator.pop(context);
      context.showErrorToast(e.toString());
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _statusLabel(LeaseStatus s) {
    switch (s) {
      case LeaseStatus.generated: return 'Ready to Sign';
      case LeaseStatus.pendingTenantSignature: return 'Awaiting Tenant Signature';
      case LeaseStatus.pendingLandlordSignature: return 'Awaiting Landlord Signature';
      case LeaseStatus.partiallySigned: return 'Partially Signed';
      case LeaseStatus.signed: return 'Fully Signed';
      case LeaseStatus.expired: return 'Expired';
      case LeaseStatus.cancelled: return 'Cancelled';
      default: return 'Draft';
    }
  }

  (Color, IconData, String) _statusDecor(LeaseStatus s) {
    switch (s) {
      case LeaseStatus.signed: return (Colors.green.shade600, Icons.verified, 'Lease Fully Signed');
      case LeaseStatus.partiallySigned: return (Colors.orange.shade600, Icons.draw, 'Partially Signed');
      case LeaseStatus.pendingTenantSignature:
      case LeaseStatus.pendingLandlordSignature:
      case LeaseStatus.generated: return (Colors.blue.shade600, Icons.description, 'Awaiting Signatures');
      case LeaseStatus.expired: return (Colors.grey, Icons.timer_off, 'Lease Expired');
      case LeaseStatus.cancelled: return (Colors.red, Icons.cancel, 'Lease Cancelled');
      default: return (Colors.grey, Icons.edit_document, 'Draft');
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.end)),
      ],
    ),
  );
}
