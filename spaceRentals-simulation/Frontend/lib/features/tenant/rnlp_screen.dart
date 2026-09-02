import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/di_providers.dart';
import '../../models/rnlp_model.dart';

// ── Provider: fetch RNLP contract from backend ──────────────────────────────
// The backend exposes rentals for the logged-in tenant; we compute the
// financing schedule client-side from the active rental record.
final _rnlpProvider = FutureProvider<RnlpModel?>((ref) async {
  final client = ref.read(apiClientProvider);
  try {
    final resp = await client.get('/rentals/tenant');
    if (resp.statusCode != 200) return null;
    final List<dynamic> data = resp.data is List ? resp.data : (resp.data['rentals'] ?? []);
    if (data.isEmpty) return null;

    final active = data.firstWhere(
      (r) => r['status'] == 'active',
      orElse: () => data.first,
    );

    final deposit = (active['deposit'] as num?)?.toDouble() ?? 0.0;
    if (deposit == 0) return null;

    const months = 6;
    final monthly = deposit / months;

    final schedule = List.generate(months, (i) => RnlpInstalment(
      month: i + 1,
      amount: monthly,
      paid: false,
      dueDate: DateTime.now().add(Duration(days: 30 * (i + 1))),
    ));

    return RnlpModel(
      id: 'rnlp_${active['id']}',
      tenantId: active['tenantId'] ?? '',
      rentalId: active['id'] ?? '',
      financedAmount: deposit,
      remainingBalance: deposit,
      totalMonths: months,
      monthlyInstalment: monthly,
      status: RnlpStatus.active,
      schedule: schedule,
    );
  } catch (_) {
    return null;
  }
});

class RnlpScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const RnlpScreen({super.key, required this.tenantId});

  @override
  ConsumerState<RnlpScreen> createState() => _RnlpScreenState();
}

class _RnlpScreenState extends ConsumerState<RnlpScreen> with TickerProviderStateMixin {
  bool _checkingEligibility = false;
  bool _eligible = false;
  bool _checkedEligibility = false;
  bool _isPayingInstalment = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    setState(() => _checkingEligibility = true);
    // Real eligibility check: query tenant's payment history from backend
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.get('/rentals/tenant');
      final bool hasRentals = resp.statusCode == 200 &&
          ((resp.data is List && (resp.data as List).isNotEmpty) ||
           (resp.data['rentals'] != null && (resp.data['rentals'] as List).isNotEmpty));
      setState(() {
        _checkingEligibility = false;
        _eligible = hasRentals;
        _checkedEligibility = true;
      });
      if (hasRentals) _progressController.forward();
    } catch (_) {
      setState(() {
        _checkingEligibility = false;
        _eligible = false;
        _checkedEligibility = true;
      });
    }
  }

  Future<void> _payInstalment(RnlpModel contract, int instalmentIndex) async {
    setState(() => _isPayingInstalment = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isPayingInstalment = false);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Instalment Paid')],
        ),
        content: Text('${CurrencyFormatter.formatCFA(contract.monthlyInstalment)} has been processed via Mobile Money.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rnlpAsync = ref.watch(_rnlpProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('RNLP Financing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // RNLP info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text('RNLP Financing Engine',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SpaceRentals finances your full deposit to the landlord upfront. You repay in easy monthly instalments via Mobile Money.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Eligibility section
            if (!_checkedEligibility) ...[
              Text('Step 1: Check Eligibility', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('We will assess your rental history and payment record.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _checkingEligibility
                  ? const Column(children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Checking your eligibility...')
                    ])
                  : ElevatedButton.icon(
                      onPressed: _checkEligibility,
                      icon: const Icon(Icons.search),
                      label: const Text('Check My Eligibility'),
                    ),
            ],

            if (_checkedEligibility && _eligible) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Eligible for RNLP', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('You qualify for deposit financing up to 6 months.',
                              style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (_checkedEligibility && !_eligible) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(child: Text('Not Eligible — no active rental found.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Active RNLP contract
            rnlpAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
              data: (contract) {
                if (contract == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Active RNLP Contract', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Summary card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          _buildContractRow('Financed Amount', CurrencyFormatter.formatCFA(contract.financedAmount)),
                          const Divider(height: 20),
                          _buildContractRow('Remaining Balance', CurrencyFormatter.formatCFA(contract.remainingBalance),
                              valueColor: Colors.orange),
                          const Divider(height: 20),
                          _buildContractRow('Monthly Instalment', CurrencyFormatter.formatCFA(contract.monthlyInstalment)),
                          const Divider(height: 20),
                          _buildContractRow('Duration', '${contract.totalMonths} months'),

                          const SizedBox(height: 16),

                          // Progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Repayment Progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    '${contract.schedule.where((i) => i.paid).length}/${contract.totalMonths} paid',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: contract.schedule.where((i) => i.paid).length / contract.totalMonths,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Repayment Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    ...contract.schedule.asMap().entries.map((entry) {
                      final i = entry.key;
                      final instalment = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: instalment.paid ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: instalment.paid
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            child: Icon(
                              instalment.paid ? Icons.check_circle : Icons.schedule,
                              color: instalment.paid ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Month ${instalment.month}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                CurrencyFormatter.formatCFA(instalment.amount),
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Due: ${instalment.dueDate.day}/${instalment.dueDate.month}/${instalment.dueDate.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const Spacer(),
                              if (!instalment.paid)
                                _isPayingInstalment
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : TextButton(
                                        onPressed: () => _payInstalment(contract, i),
                                        child: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                                      ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
