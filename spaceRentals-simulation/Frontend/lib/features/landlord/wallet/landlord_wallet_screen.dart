import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/landlord_wallet_provider.dart';
import '../domain/landlord_wallet.dart';

class LandlordWalletScreen extends ConsumerWidget {
  const LandlordWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(landlordWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet & Payouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error loading wallet: $err')),
        data: (wallet) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(landlordWalletProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _WalletBalanceCard(wallet: wallet),
              const SizedBox(height: 24),
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (wallet.entries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No transactions yet.', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...wallet.entries.map((entry) => _TransactionTile(entry: entry)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletBalanceCard extends ConsumerStatefulWidget {
  final LandlordWallet wallet;
  const _WalletBalanceCard({required this.wallet});

  @override
  ConsumerState<_WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends ConsumerState<_WalletBalanceCard> {
  bool _isWithdrawing = false;

  void _showWithdrawalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawalSheet(
        maxAmount: widget.wallet.balance,
        onSubmit: (amount, method, destination) async {
          Navigator.pop(context);
          setState(() => _isWithdrawing = true);
          try {
            await ref.read(landlordWalletRepositoryProvider).requestWithdrawal(amount, method, destination);
            ref.invalidate(landlordWalletProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Withdrawal requested successfully!'),
                backgroundColor: AppColors.success,
              ));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error,
              ));
            }
          } finally {
            if (mounted) setState(() => _isWithdrawing = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatCFA(widget.wallet.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.wallet.pendingBalance > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.pending_actions, color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Pending Clearance: \${CurrencyFormatter.formatCFA(widget.wallet.pendingBalance)}',
                  style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isWithdrawing || widget.wallet.balance <= 0 ? null : _showWithdrawalSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isWithdrawing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Cash Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final LandlordWalletEntry entry;
  const _TransactionTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCredit = entry.amount > 0;
    final icon = entry.type == 'withdrawal'
        ? Icons.account_balance_wallet
        : entry.type == 'platform_fee_deduction'
            ? Icons.money_off
            : Icons.arrow_downward;

    final color = entry.type == 'platform_fee_deduction'
        ? Colors.grey
        : isCredit
            ? AppColors.success
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(entry.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\${isCredit ? '+' : ''}\${CurrencyFormatter.formatCFA(entry.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalSheet extends StatefulWidget {
  final double maxAmount;
  final Function(double amount, String method, String destination) onSubmit;

  const _WithdrawalSheet({required this.maxAmount, required this.onSubmit});

  @override
  State<_WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends State<_WithdrawalSheet> {
  final _amountCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  String _method = 'MTN';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cash Out', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Max available: \${CurrencyFormatter.formatCFA(widget.maxAmount)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _method,
              decoration: const InputDecoration(
                labelText: 'Withdrawal Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'MTN', child: Text('MTN Mobile Money')),
                DropdownMenuItem(value: 'ORANGE', child: Text('Orange Money')),
                DropdownMenuItem(value: 'BANK', child: Text('Bank Transfer')),
              ],
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (XAF)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destCtrl,
              keyboardType: _method == 'BANK' ? TextInputType.text : TextInputType.phone,
              decoration: InputDecoration(
                labelText: _method == 'BANK' ? 'Bank Account Number / IBAN' : 'Phone Number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(_amountCtrl.text) ?? 0;
                  if (amt <= 0 || amt > widget.maxAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount.')));
                    return;
                  }
                  if (_destCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a destination.')));
                    return;
                  }
                  widget.onSubmit(amt, _method, _destCtrl.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Confirm Cash Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
