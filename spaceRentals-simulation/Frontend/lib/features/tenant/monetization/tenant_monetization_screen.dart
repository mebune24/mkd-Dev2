import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/ui_helpers.dart';

class TenantMonetizationScreen extends StatefulWidget {
  const TenantMonetizationScreen({super.key});

  @override
  State<TenantMonetizationScreen> createState() => _TenantMonetizationScreenState();
}

class _TenantMonetizationScreenState extends State<TenantMonetizationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Gains & Parrainage'),
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
          tabs: const [
            Tab(text: 'Mon Portefeuille'),
            Tab(text: 'Parrainage'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWalletTab(theme),
          _buildReferralTab(theme),
        ],
      ),
    );
  }

  Widget _buildWalletTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Wallet Card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, const Color(0xFF4A2B56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text('Solde du portefeuille', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatCFA(25000),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.home, size: 18),
                        label: const Text('Appliquer au loyer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.phone_android, size: 18),
                        label: const Text('Retrait Mobile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('Historique des Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTransactionTile(title: 'Bonus de parrainage - Alice', date: 'Hier', amount: 15000, isCredit: true),
          _buildTransactionTile(title: 'Micro-tâche : Tonte pelouse', date: '12 Août 2026', amount: 10000, isCredit: true),
          _buildTransactionTile(title: 'Déduction loyer', date: '1 Août 2026', amount: -25000, isCredit: false),
        ],
      ),
    );
  }

  Widget _buildReferralTab(ThemeData theme) {
    const String referralCode = 'SPACE-78XY';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero Banner ──────────────────────────────
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
                  decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.celebration, color: Colors.orange, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gagnez ${CurrencyFormatter.formatCFA(15000)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                      const Text('sur votre prochain loyer par ami invité !', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Code Share ─────────────────────────────
          const Text('Votre Code de Parrainage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(referralCode, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: theme.colorScheme.primary)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: referralCode));
                        context.showToast('Code copié !');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Pipeline Tracker ───────────────────────
          const Text('Suivi de Parrainage Actuel (Alice M.)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildPipelineStep(title: 'Lien partagé', subtitle: 'Alice a cliqué sur le lien', isCompleted: true, isLast: false, theme: theme),
          _buildPipelineStep(title: 'Compte créé', subtitle: 'Profil vérifié', isCompleted: true, isLast: false, theme: theme),
          _buildPipelineStep(title: 'Premier loyer payé', subtitle: 'Bonus débloqué', isCompleted: false, isLast: true, theme: theme),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({required String title, required String date, required double amount, required bool isCredit}) {
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
            backgroundColor: isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}${CurrencyFormatter.formatCFA(amount)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCredit ? Colors.green : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStep({required String title, required String subtitle, required bool isCompleted, required bool isLast, required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? theme.colorScheme.primary : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : const Icon(Icons.circle, size: 8, color: Colors.grey),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? theme.colorScheme.primary : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCompleted ? Colors.black87 : Colors.grey)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
