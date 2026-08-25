import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'my_properties.dart';
import 'tenant_management.dart';
import 'landlord_payments_screen.dart';
import 'my_agents_screen.dart';
import '../profile/profile_screen.dart';
import 'monetization/landlord_monetization_screen.dart';

class LandlordDashboard extends ConsumerStatefulWidget {
  const LandlordDashboard({super.key});

  @override
  ConsumerState<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends ConsumerState<LandlordDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardOverview(),
    const MyProperties(),
    const TenantManagementScreen(),
    const LandlordPaymentsScreen(),
    const MyAgentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: _LandlordDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_currentIndex != 1) ...[ // only show waitlist/whatsapp when AI bot is showing
            Container(
              margin: const EdgeInsets.only(right: 68),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Join the waitlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentIndex != 1) ...[
                FloatingActionButton(
                  heroTag: 'whatsapp_fab_landlord',
                  onPressed: () async {
                    final Uri url = Uri.parse('https://wa.me/652856939');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  tooltip: 'Join Waitlist via WhatsApp',
                  child: const FaIcon(FontAwesomeIcons.whatsapp, size: 30),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton(
                heroTag: 'ai_fab_landlord',
                onPressed: _currentIndex == 1
                    ? () => context.push('/landlord/add-property')
                    : () => context.push('/chatbot'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tooltip: _currentIndex == 1 ? 'Add Property' : 'SpaceBot AI',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _currentIndex == 1
                          ? [theme.colorScheme.primary, theme.colorScheme.primary]
                          : [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(_currentIndex == 1 ? Icons.add : Icons.auto_awesome, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Overview', index: 0, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.business_outlined, activeIcon: Icons.business_rounded, label: 'Properties', index: 1, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Tenants', index: 2, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'Payments', index: 3, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.real_estate_agent_outlined, activeIcon: Icons.real_estate_agent, label: 'Agents', index: 4, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', index: 5, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;
  final ThemeData theme;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.currentIndex, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? theme.colorScheme.primary : Colors.grey, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? theme.colorScheme.primary : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// Hamburger Drawer for Landlord dashboard
class _LandlordDrawer extends StatelessWidget {
  const _LandlordDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.business, size: 42, color: Colors.white),
                SizedBox(height: 12),
                Text('Tableau de Bord Bailleur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Gérez vos propriétés et vos revenus', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerTile(
                  context,
                  icon: Icons.savings,
                  color: Colors.green,
                  label: 'Revenus & Parrainage',
                  subtitle: 'Commissions, bonus bailleurs',
                  onTap: () { Navigator.pop(context); context.push('/landlord/monetization'); },
                ),
                _buildDrawerTile(
                  context,
                  icon: Icons.task_alt,
                  color: Colors.orange,
                  label: 'Publier une Tâche',
                  subtitle: 'Entretien, nettoyage...',
                  onTap: () { Navigator.pop(context); context.push('/landlord/post-gig'); },
                ),
                _buildDrawerTile(
                  context,
                  icon: Icons.notifications_outlined,
                  color: Colors.blue,
                  label: 'Notifications',
                  subtitle: '',
                  onTap: () { Navigator.pop(context); context.push('/notifications'); },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context, {required IconData icon, required Color color, required String label, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }
}

class _ChatNavItem extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ChatNavItem({required this.currentIndex, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [theme.colorScheme.primary, const Color(0xFF5D3F6A)]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? theme.colorScheme.primary : Colors.grey).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
      ),
    );
  }
}

class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Good day, ${user.session?.fullName.split(' ').first ?? 'Landlord'} 👋',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Landlord Dashboard',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        if (false) // TODO: wire kycStatus from backend API response
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 4),
                                Text('Premium Landlord', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Badge(child: Icon(Icons.notifications_outlined, color: Colors.white)),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/login');
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'Properties', '2', Icons.business_rounded, theme.colorScheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Tenants', '1', Icons.people_rounded, Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'Monthly Revenue', CurrencyFormatter.formatCFA(150000), Icons.payments_rounded, Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Pending Apps', '1', Icons.pending_actions_rounded, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick actions
                  Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(context, Icons.add_business, 'Add Property', theme.colorScheme.primary, () => context.push('/landlord/add-property'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.auto_awesome, 'Ask SpaceBot', const Color(0xFF5D3F6A), () => context.push('/chatbot'))),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent activity
                  Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildActivityTile(context, Icons.description, theme.colorScheme.primary, 'New Rental Application', 'Tenant applied for Modern 2 Bedroom Apartment', '2h ago'),
                  const SizedBox(height: 12),
                  _buildActivityTile(context, Icons.payments, Colors.green, 'Payment Received', '150,000 FCFA rent received from tenant', 'Aug 1'),
                  const SizedBox(height: 12),
                  _buildActivityTile(context, Icons.handyman, Colors.orange, 'Maintenance Request', 'Plumbing issue reported at property #1', '3 days ago'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, IconData icon, Color color, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
