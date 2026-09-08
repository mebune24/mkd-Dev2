import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../features/tenant/domain/tenant_wallet.dart';
import '../../../providers/di_providers.dart';
import '../../../providers/domain_providers.dart';
import '../../../providers/locale_provider.dart';

class TenantMonetizationScreen extends ConsumerStatefulWidget {
  const TenantMonetizationScreen({super.key});

  @override
  ConsumerState<TenantMonetizationScreen> createState() =>
      _TenantMonetizationScreenState();
}

class _TenantMonetizationScreenState
    extends ConsumerState<TenantMonetizationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isFr ? 'Gains & Parrainage' : 'Earnings & Referrals'),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: isFr ? 'Mon Portefeuille' : 'My Wallet'),
            Tab(text: isFr ? 'Parrainage' : 'Referral'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWalletTab(theme, isFr),
          _buildReferralTab(theme, isFr),
        ],
      ),
    );
  }

  Widget _buildWalletTab(ThemeData theme, bool isFr) {
    final walletAsync = ref.watch(tenantWalletProvider);

    return walletAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isFr
                ? 'Impossible de charger le portefeuille'
                : 'Unable to load wallet',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      data: (wallet) => _WalletBody(
        wallet: wallet,
        theme: theme,
        isFr: isFr,
        onApplyToRent: () async => _applyToRent(wallet, isFr),
        onWithdraw: () async => _withdraw(wallet, isFr),
      ),
    );
  }

  Widget _buildReferralTab(ThemeData theme, bool isFr) {
    final walletAsync = ref.watch(tenantWalletProvider);
    final referralCode = walletAsync.maybeWhen(
      data: (wallet) => wallet.referralCode,
      orElse: () => 'SPACE-REF',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFr
                            ? 'Gagnez ${CurrencyFormatter.formatCFA(15000)}'
                            : 'Earn ${CurrencyFormatter.formatCFA(15000)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        isFr
                            ? 'sur votre prochain loyer par ami invité !'
                            : 'on your next rent by inviting a friend!',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isFr ? 'Votre Code de Parrainage' : 'Your Referral Code',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referralCode,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        context.showToast(
                          isFr ? 'Code copié !' : 'Code copied!',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isFr ? 'Suivi de Parrainage Actuel' : 'Current Referral Tracking',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildPipelineStep(
            title: isFr ? 'Lien partagé' : 'Link shared',
            subtitle: isFr
                ? 'Votre ami a ouvert le lien'
                : 'Your friend opened the link',
            isCompleted: true,
            isLast: false,
            theme: theme,
          ),
          _buildPipelineStep(
            title: isFr ? 'Compte créé' : 'Account created',
            subtitle: isFr ? 'Profil vérifié' : 'Profile verified',
            isCompleted: true,
            isLast: false,
            theme: theme,
          ),
          _buildPipelineStep(
            title: isFr ? 'Premier loyer payé' : 'First rent paid',
            subtitle: isFr ? 'Bonus débloqué' : 'Bonus unlocked',
            isCompleted: false,
            isLast: true,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _applyToRent(TenantWallet wallet, bool isFr) async {
    final rootContext = context;
    final messenger = ScaffoldMessenger.maybeOf(rootContext);
    if (wallet.balance <= 0) {
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              isFr ? 'Aucun solde disponible' : 'No balance available',
            ),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: rootContext,
      builder: (_) => AlertDialog(
        title: Text(isFr ? 'Appliquer au loyer' : 'Apply to rent'),
        content: Text(
          isFr
              ? 'Voulez-vous utiliser ${CurrencyFormatter.formatCFA(wallet.balance.toDouble())} de votre portefeuille pour votre loyer ?'
              : 'Use ${CurrencyFormatter.formatCFA(wallet.balance.toDouble())} from your wallet against your rent?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(rootContext, false),
            child: Text(isFr ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(rootContext, true),
            child: Text(isFr ? 'Confirmer' : 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(tenantWalletRepositoryProvider);
      await repo.applyToRent(wallet.balance);
      ref.invalidate(tenantWalletProvider);
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              isFr ? 'Solde appliqué au loyer' : 'Balance applied to rent',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger?.showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _withdraw(TenantWallet wallet, bool isFr) async {
    final rootContext = context;
    final messenger = ScaffoldMessenger.maybeOf(rootContext);
    if (wallet.balance <= 0) {
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(isFr ? 'Solde insuffisant' : 'Insufficient balance'),
          ),
        );
      }
      return;
    }

    final method = await showDialog<String>(
      context: rootContext,
      builder: (_) => SimpleDialog(
        title: Text(
          isFr ? 'Choisissez le mode de retrait' : 'Select withdrawal method',
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(rootContext, 'MTN'),
            child: const Text('MTN Mobile Money'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(rootContext, 'ORANGE'),
            child: const Text('Orange Money'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(rootContext, 'BANK_CARD'),
            child: const Text('Bank Card'),
          ),
        ],
      ),
    );

    if (method == null || method.isEmpty) return;
    if (!mounted) return;

    final destinationController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFr ? 'Détails du retrait' : 'Withdrawal details'),
        content: TextField(
          controller: destinationController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: isFr
                ? 'Numéro de téléphone ou carte'
                : 'Phone number or card',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(rootContext, false),
            child: Text(isFr ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(rootContext, true),
            child: Text(isFr ? 'Demander' : 'Request'),
          ),
        ],
      ),
    );

    if (confirmed != true || destinationController.text.trim().isEmpty) return;

    try {
      final repo = ref.read(tenantWalletRepositoryProvider);
      await repo.withdraw(
        amount: wallet.balance,
        method: method,
        destination: destinationController.text.trim(),
      );
      ref.invalidate(tenantWalletProvider);
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              isFr ? 'Demande de retrait envoyée' : 'Withdrawal request sent',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger?.showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Widget _buildPipelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? theme.colorScheme.primary
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const Icon(Icons.circle, size: 8, color: Colors.grey),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({
    required this.wallet,
    required this.theme,
    required this.isFr,
    required this.onApplyToRent,
    required this.onWithdraw,
  });

  final TenantWallet wallet;
  final ThemeData theme;
  final bool isFr;
  final Future<void> Function() onApplyToRent;
  final Future<void> Function() onWithdraw;

  @override
  Widget build(BuildContext context) {
    final entryTiles = wallet.entries.isEmpty
        ? [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Text(
                isFr
                    ? 'Aucune transaction pour le moment'
                    : 'No transactions yet',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ]
        : wallet.entries
              .map(
                (entry) => _TransactionEntryTile(
                  title: entry.description,
                  date: entry.createdAt.toLocal().toString().split(' ')[0],
                  amount: entry.amount,
                  isCredit: entry.amount >= 0,
                ),
              )
              .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, const Color(0xFF4A2B56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFr ? 'Solde du portefeuille' : 'Wallet balance',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatCFA(wallet.balance.toDouble()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async => onApplyToRent(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.home, size: 18),
                        label: Text(
                          isFr ? 'Appliquer au loyer' : 'Apply to rent',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async => onWithdraw(),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone_android, size: 18),
                        label: Text(
                          isFr ? 'Retrait Mobile' : 'Mobile withdrawal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isFr ? 'Historique des Transactions' : 'Transaction history',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...entryTiles,
        ],
      ),
    );
  }
}

class _TransactionEntryTile extends StatelessWidget {
  const _TransactionEntryTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });

  final String title;
  final String date;
  final int amount;
  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCredit
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${CurrencyFormatter.formatCFA(amount.abs().toDouble())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isCredit ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
