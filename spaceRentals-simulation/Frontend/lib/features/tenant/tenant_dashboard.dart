import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import '../../core/utils/currency_formatter.dart';
import '../profile/profile_screen.dart';
import 'favorites_screen.dart';
import 'messages_screen.dart';

class TenantDashboard extends ConsumerStatefulWidget {
  const TenantDashboard({super.key});

  @override
  ConsumerState<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends ConsumerState<TenantDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const MessagesScreen(),
      _MyRentals(tenantId: user.session?.userId),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: _TenantDrawer(user: ref.read(authProvider)),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'whatsapp_fab_tenant',
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
              FloatingActionButton(
                heroTag: 'ai_fab_tenant',
                onPressed: () => context.push('/chatbot'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tooltip: 'SpaceBot AI',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', index: 0, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded, label: 'Saved', index: 1, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Messages', index: 2, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.key_outlined, activeIcon: Icons.key_rounded, label: 'My Rentals', index: 3, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', index: 4, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(isActive ? activeIcon : icon, key: ValueKey(isActive), color: isActive ? theme.colorScheme.primary : Colors.grey, size: 22),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? theme.colorScheme.primary : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// Hamburger Drawer for Tenant dashboard
class _TenantDrawer extends StatelessWidget {
  final dynamic user;
  const _TenantDrawer({required this.user});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    user.session?.fullName.substring(0, 1).toUpperCase() ?? 'G',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Text(user.session?.fullName ?? 'Guest', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(user?.session?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    CurrencyFormatter.formatCFA(25000),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _DrawerTile(
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                  label: 'Portefeuille & Gains',
                  subtitle: 'Solde, parrainage & cashout',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tenant/monetization');
                  },
                ),
                _DrawerTile(
                  icon: Icons.handshake,
                  color: Colors.orange,
                  label: 'Micro-Tâches',
                  subtitle: 'Gagnez en aidant votre communauté',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tenant/gigs');
                  },
                ),
                _DrawerTile(
                  icon: Icons.real_estate_agent,
                  color: const Color(0xFF6A1B9A),
                  label: 'Devenir Agent',
                  subtitle: 'Gagnez des commissions de location',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/agent/onboarding');
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _DrawerTile(
                  icon: Icons.notifications_outlined,
                  color: Colors.blue,
                  label: 'Notifications',
                  subtitle: '',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/notifications');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

/// My Rentals tab
class _MyRentals extends ConsumerWidget {
  final String? tenantId;
  const _MyRentals({required this.tenantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (tenantId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Rentals'),
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: Icon(Icons.key_off, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                Text('No Rentals Available', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Please log in or create an account to view and manage your rentals.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In to View Rentals', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('My Rentals'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                        SizedBox(width: 6),
                        Text('Active Rental', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Modern 2 Bedroom Apartment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  const Row(children: [Icon(Icons.location_on, color: Colors.white70, size: 14), SizedBox(width: 4), Text('Bastos, Yaoundé', style: TextStyle(color: Colors.white70, fontSize: 13))]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Monthly Rent', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        Text(CurrencyFormatter.formatCFA(150000), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Text('Due Aug 31', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Rental Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionTile(context, icon: Icons.description, color: theme.colorScheme.primary, title: 'Rental Agreement', subtitle: 'View and confirm your agreement', onTap: () => context.push('/tenant/agreement', extra: tenantId!)),
            const SizedBox(height: 12),
            _buildActionTile(context, icon: Icons.payments, color: Colors.teal, title: 'Payments', subtitle: 'View history and pay rent', onTap: () => context.push('/tenant/payments', extra: tenantId!)),
            const SizedBox(height: 12),
            _buildActionTile(context, icon: Icons.account_balance, color: Colors.indigo, title: 'RNLP Financing', subtitle: 'Manage your deposit financing', onTap: () => context.push('/tenant/rnlp', extra: tenantId!)),
            const SizedBox(height: 12),
            _buildActionTile(context, icon: Icons.handyman, color: Colors.orange, title: 'Maintenance & Services', subtitle: 'Request repairs and premium services', onTap: () => context.push('/tenant/maintenance', extra: tenantId!)),
            const SizedBox(height: 28),
            Text('History & Tracking', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionTile(context, icon: Icons.history, color: Colors.blueGrey, title: 'Operations History', subtitle: 'Track your payments, RNLP, and requests', onTap: () => _showHistoryModal(context, theme)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Operations History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _historyRow(Icons.payments, Colors.teal, 'Rent Paid — 150,000 CFA', 'August 1, 2026'),
            _historyRow(Icons.handyman, Colors.orange, 'Plumbing Repair', 'July 20, 2026'),
            _historyRow(Icons.account_balance, Colors.indigo, 'RNLP Disbursed', 'June 15, 2026'),
            _historyRow(Icons.description, theme.colorScheme.primary, 'Agreement Signed', 'June 10, 2026'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(IconData icon, Color color, String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Colors.grey, size: 18)),
          ],
        ),
      ),
    );
  }
}
