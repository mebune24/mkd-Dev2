import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/currency_formatter.dart';

class AgentOnboardingScreen extends StatelessWidget {
  const AgentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Section ─────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.real_estate_agent, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Become a SpaceRentals Agent',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Turn your network into income. Help tenants find their dream homes and earn commissions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
            
            // ── Benefits Section ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Exclusive Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildBenefitTile(
                    icon: Icons.payments,
                    color: Colors.green,
                    title: 'Attractive Commissions',
                    subtitle: 'Earn up to ${CurrencyFormatter.formatCFA(50000)} per completed rental.',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitTile(
                    icon: Icons.access_time,
                    color: Colors.orange,
                    title: 'Total Flexibility',
                    subtitle: 'Work whenever you want, from anywhere in Cameroon.',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitTile(
                    icon: Icons.trending_up,
                    color: Colors.indigo,
                    title: 'Landlord Network',
                    subtitle: 'Access hundreds of exclusive premium properties.',
                  ),
                ],
              ),
            ),

            // ── Call to Action ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.push('/agent/kyc');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    child: const Text('Start Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
