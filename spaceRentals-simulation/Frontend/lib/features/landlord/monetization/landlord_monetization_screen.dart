import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';

class LandlordMonetizationScreen extends StatefulWidget {
  const LandlordMonetizationScreen({super.key});

  @override
  State<LandlordMonetizationScreen> createState() => _LandlordMonetizationScreenState();
}

class _LandlordMonetizationScreenState extends State<LandlordMonetizationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Revenus & Parrainage'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Passive Income Summary ────────────────────────
            const Text('Revenus Auxiliaires Mensuels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard(label: 'Commissions Services', value: 45000, color: Colors.green, icon: Icons.payments)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(label: 'Bonus Parrainage', value: 60000, color: Colors.purple, icon: Icons.group_add)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard(label: 'Tâches Publiées', value: 3, isCurrency: false, color: Colors.orange, icon: Icons.task_alt)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(label: 'Tâches Complétées', value: 2, isCurrency: false, color: Colors.teal, icon: Icons.check_circle)),
              ],
            ),

            const SizedBox(height: 32),

            // ── Manager Referral Hero Banner ────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.greenAccent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Programme Bailleur Premium',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagnez ${CurrencyFormatter.formatCFA(60000)} par bailleur parrainé !',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 20),
                  const _PremiumStatusRow(),
                  const SizedBox(height: 20),
                  const _ReferralLedger(),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Partager mon code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Post Gig CTA ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Publier une Micro-Tâche', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Faites entretenir votre propriété par la communauté', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/landlord/post-gig'),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Créer une tâche'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String label, required num value, required Color color, required IconData icon, bool isCurrency = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            isCurrency ? CurrencyFormatter.formatCFA(value.toDouble()) : '$value',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PremiumStatusRow extends StatelessWidget {
  const _PremiumStatusRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        children: [
          Icon(Icons.workspace_premium, color: Colors.greenAccent, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statut Premium Actif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('3 mois offerts restants', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralLedger extends StatelessWidget {
  const _ReferralLedger();

  final _ledger = const [
    {'name': 'Jean-Pierre N.', 'status': 'Validé', 'amount': 60000.0},
    {'name': 'Marie-Claire A.', 'status': 'En attente', 'amount': 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historique Parrainages', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ..._ledger.map((e) {
          final isValidated = e['status'] == 'Validé';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13)),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isValidated ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(e['status'] as String, style: TextStyle(color: isValidated ? Colors.greenAccent : Colors.orange, fontSize: 11)),
                  ),
                  if (isValidated) ...[
                    const SizedBox(width: 8),
                    Text(CurrencyFormatter.formatCFA(e['amount'] as double), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ]
                ]),
              ],
            ),
          );
        }),
      ],
    );
  }
}
