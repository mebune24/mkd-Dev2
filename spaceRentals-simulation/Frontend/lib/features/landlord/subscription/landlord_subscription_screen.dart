import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/di_providers.dart';

class LandlordSubscriptionScreen extends ConsumerStatefulWidget {
  const LandlordSubscriptionScreen({super.key});

  @override
  ConsumerState<LandlordSubscriptionScreen> createState() =>
      _LandlordSubscriptionScreenState();
}

class _LandlordSubscriptionScreenState
    extends ConsumerState<LandlordSubscriptionScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _currentPlan;
  String _selectedPlanId = 'starter';

  static const _plans = [
    {
      'id': 'starter',
      'name': 'Starter',
      'price': 5000,
      'listingLimit': 3,
      'features': ['3 active listings', 'Basic support', 'Application management'],
    },
    {
      'id': 'growth',
      'name': 'Growth',
      'price': 15000,
      'listingLimit': 10,
      'features': ['10 active listings', 'Priority support', 'Analytics dashboard'],
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'price': 30000,
      'listingLimit': 50,
      'features': ['50 active listings', 'Dedicated support', 'Full analytics', 'Priority listing boost'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.get('/subscriptions/status');
      if (res.isSuccess && mounted) {
        setState(() => _currentPlan = res.data as Map<String, dynamic>?);
      }
    } catch (_) {}
  }

  Future<void> _subscribe() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your Mobile Money number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final session = ref.read(apiClientProvider);
      final res = await client.post('/subscriptions/initiate', data: {
        'planId': _selectedPlanId,
        'phoneNumber': _phoneCtrl.text.trim(),
        'email': '', // filled server-side from token
        'paymentMethod': 'MTN',
      });

      if (!res.isSuccess) throw Exception(res.error?.message ?? 'Subscription failed.');

      final data = res.data as Map<String, dynamic>;
      final link = data['payment']?['paymentLink'] as String?;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(link != null
                ? 'Check your phone to approve the payment!'
                : 'Subscription activated!'),
            backgroundColor: Colors.green,
          ),
        );
        if (link == null) context.pop();
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
    final activeStatus = _currentPlan?['status'] as String?;
    final activePlanId = _currentPlan?['subscription']?['planId'] as String?;
    final isActive = activeStatus == 'active' || activeStatus == 'grace_period';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription Plans',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (isActive) ...[
            _ActiveBanner(activePlanId: activePlanId),
            const SizedBox(height: 24),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free tier: 1 active listing. Subscribe to unlock more.',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Choose a Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          ..._plans.map((plan) => _PlanCard(
                plan: plan,
                isSelected: _selectedPlanId == plan['id'],
                isCurrent: activePlanId == plan['id'] && isActive,
                onTap: isActive ? null : () => setState(() => _selectedPlanId = plan['id'] as String),
              )),
          if (!isActive) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Money Number (e.g. 6XXXXXXXX)',
                prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _subscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Subscribe — ${CurrencyFormatter.formatCFA(_plans.firstWhere((p) => p['id'] == _selectedPlanId)['price'] as double)}/mo',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  final String? activePlanId;
  const _ActiveBanner({this.activePlanId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7B2FBE)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: AppColors.accent, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(activePlanId ?? 'starter')[0].toUpperCase()}${(activePlanId ?? 'starter').substring(1)} Plan Active',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text('Your subscription is active', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? Colors.green
                : isSelected
                    ? AppColors.primary
                    : Colors.grey.shade200,
            width: isSelected || isCurrent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan['name'] as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Current',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${CurrencyFormatter.formatCFA((plan['price'] as int).toDouble())}/month',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Up to ${plan['listingLimit']} listings',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            ...(plan['features'] as List).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(f as String, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
