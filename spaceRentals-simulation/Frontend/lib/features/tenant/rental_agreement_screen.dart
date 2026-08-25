import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/rental_model.dart';
import '../../services/mock_rental_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/audit_log_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'checkout/ancillary_services_widget.dart';

final _rentalServiceProvider = Provider((ref) => MockRentalService());

final _activeRentalProvider = FutureProvider.family<RentalModel, String>((ref, tenantId) async {
  return ref.read(_rentalServiceProvider).getActiveRental(tenantId);
});

class RentalAgreementScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const RentalAgreementScreen({super.key, required this.tenantId});

  @override
  ConsumerState<RentalAgreementScreen> createState() => _RentalAgreementScreenState();
}

class _RentalAgreementScreenState extends ConsumerState<RentalAgreementScreen> {
  bool _isConfirming = false;
  bool _tenantConfirmed = false;
  bool _signatureLogged = false;
  double? _totalRent;

  Widget _buildStatusChip(String label, bool confirmed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: confirmed ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: confirmed ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(confirmed ? Icons.check_circle : Icons.pending, size: 14,
              color: confirmed ? Colors.green : Colors.orange),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: confirmed ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rentalAsync = ref.watch(_activeRentalProvider(widget.tenantId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Agreement')),
      body: rentalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rental) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.description, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text('Rental Agreement', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        rental.status.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Agreement details
              Text('Agreement Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDetailRow('Monthly Rent', CurrencyFormatter.formatCFA(rental.rent)),
              _buildDetailRow('Security Deposit', CurrencyFormatter.formatCFA(rental.deposit)),
              _buildDetailRow('Rental ID', rental.id),
              _buildDetailRow('Property ID', rental.propertyId),
              const Divider(height: 32),

              // Signatures
              Text('Confirmations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Tenant', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildStatusChip('Confirmed', _tenantConfirmed),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Landlord', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildStatusChip('Confirmed', rental.landlordConfirmed),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // OHADA compliance banner
              if (_tenantConfirmed) ...[  
                Builder(builder: (context) {
                  // Log signature on first render if not yet logged
                  if (!_signatureLogged) {
                    _signatureLogged = true;
                    final user = ref.read(authProvider);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(auditLogProvider.notifier).logLeaseSignature(
                        tenantId: widget.tenantId,
                        tenantName: user.session?.fullName ?? 'Tenant',
                        propertyId: rental.propertyId,
                        rentalId: rental.id,
                      );
                    });
                  }
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.indigo, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This agreement is electronically signed and timestamped in compliance with OHADA Uniform Act and Cameroon Law No. 2010/021.',
                            style: TextStyle(fontSize: 11, color: Colors.indigo, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              
              if (!_tenantConfirmed) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isConfirming ? null : () async {
                      setState(() => _isConfirming = true);
                      
                      // Generate SHA-256 e-signature hash
                      final user = ref.read(authProvider);
                      final rawData = '${rental.id}|${user.session?.userId}|${DateTime.now().toIso8601String()}';
                      final bytes = utf8.encode(rawData);
                      final signatureHash = sha256.convert(bytes).toString();
                      
                      // Simulate network delay and API call with hash & IP
                      await Future.delayed(const Duration(seconds: 1));
                      
                      setState(() {
                        _tenantConfirmed = true;
                        _isConfirming = false;
                      });
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Agreement signed electronically.'),
                            backgroundColor: Colors.green,
                          )
                        );
                      }
                    },
                    icon: _isConfirming 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.draw),
                    label: Text(_isConfirming ? 'Signing...' : 'Sign Agreement Electronically'),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              if (_tenantConfirmed) ...[
                AncillaryServicesWidget(
                  baseRent: rental.rent,
                  onTotalChanged: (newTotal, services) {
                    setState(() {
                      _totalRent = newTotal;
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
              
              const Divider(),
              const SizedBox(height: 16),

              // Payment action
              Text('Next Payment Due', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('September 2026', style: theme.textTheme.bodyMedium),
                        Text(CurrencyFormatter.formatCFA(_totalRent ?? rental.rent),
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/tenant/payments'),
                      icon: const Icon(Icons.payments),
                      label: const Text('Pay Now'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/tenant/rnlp'),
                icon: const Icon(Icons.account_balance),
                label: const Text('View RNLP Financing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
