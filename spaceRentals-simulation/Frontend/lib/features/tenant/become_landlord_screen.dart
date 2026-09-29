import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/di_providers.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/enums.dart';

class BecomeLandlordScreen extends ConsumerStatefulWidget {
  const BecomeLandlordScreen({super.key});

  @override
  ConsumerState<BecomeLandlordScreen> createState() => _BecomeLandlordScreenState();
}

class _BecomeLandlordScreenState extends ConsumerState<BecomeLandlordScreen> {
  bool _isLoading = false;

  Future<void> _upgradeRole() async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post('/users/upgrade-to-landlord');
      if (!res.isSuccess) {
        throw Exception(res.error?.message ?? 'Failed to upgrade role.');
      }

      // Update in-memory session role so the router redirects to /landlord/kyc
      await ref.read(authProvider.notifier).updateSessionRole(Role.landlord);

      if (mounted) {
        context.go('/landlord/kyc');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Become a Landlord', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.home_work_rounded, size: 80, color: AppColors.accent),
              const SizedBox(height: 24),
              const Text(
                'Ready to start earning?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upgrade your account to a Landlord profile. List your properties, manage tenants, and receive direct payments instantly through the Space Rentals P2P network.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              _buildBenefit('Zero Middlemen', 'Connect directly with verified tenants.', Icons.people_alt),
              _buildBenefit('Secure Payments', 'Automated rent collection directly to your wallet.', Icons.account_balance_wallet),
              _buildBenefit('Smart Management', 'Handle leases and maintenance directly in the app.', Icons.assignment_turned_in),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _upgradeRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Start Hosting Now',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
