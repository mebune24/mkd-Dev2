import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/domain_providers.dart';
import '../../providers/applications_provider.dart';
import '../../features/applications/domain/application.dart';
import '../../shared/models/enums.dart';
import '../../core/utils/url_helper.dart';
import '../../widgets/guest_guard.dart';
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
                onPressed: () => UrlHelper.openWhatsApp(
                  context,
                  'https://chat.whatsapp.com/JoffOh0nVQr4maaqFPdsex?s=cl&p=a&ilr=4',
                ),
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
                _NavItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded, label: 'Saved', index: 1, currentIndex: _currentIndex, onTap: (i) => GuestGuard.check(context, ref, () => setState(() => _currentIndex = i), featureName: 'saved properties'), theme: theme),
                _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Messages', index: 2, currentIndex: _currentIndex, onTap: (i) => GuestGuard.check(context, ref, () => setState(() => _currentIndex = i), featureName: 'messages'), theme: theme),
                _NavItem(icon: Icons.key_outlined, activeIcon: Icons.key_rounded, label: 'My Rentals', index: 3, currentIndex: _currentIndex, onTap: (i) => GuestGuard.check(context, ref, () => setState(() => _currentIndex = i), featureName: 'your rentals'), theme: theme),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', index: 4, currentIndex: _currentIndex, onTap: (i) => GuestGuard.check(context, ref, () => setState(() => _currentIndex = i), featureName: 'your profile'), theme: theme),
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
class _TenantDrawer extends ConsumerWidget {
  final dynamic user;
  const _TenantDrawer({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = user.session;
    
    // Calculate real balance
    final transactions = ref.watch(agentTransactionsProvider);
    final myTx = transactions.where((t) => t.agentId == session?.userId).toList();
    final balance = myTx.where((t) => t.status == 'Approved' || t.status == 'Available').fold(0.0, (s, t) => s + t.amount);
    
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
                    CurrencyFormatter.formatCFA(balance),
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
                    GuestGuard.check(context, ref, () => context.push('/tenant/monetization'), featureName: 'wallet & earnings');
                  },
                ),
                _DrawerTile(
                  icon: Icons.handshake,
                  color: Colors.orange,
                  label: 'Micro-Tâches',
                  subtitle: 'Gagnez en aidant votre communauté',
                  onTap: () {
                    Navigator.pop(context);
                    GuestGuard.check(context, ref, () => context.push('/tenant/gigs'), featureName: 'micro-gigs');
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

    final applicationsAsync = ref.watch(tenantApplicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('My Rentals & Applications'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load rentals: $e')),
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No rentals yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  const Text('Start by searching for properties and applying.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final app = applications[index];
              final isApproved = app.status == ApplicationStatus.approved;
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isApproved 
                      ? LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: isApproved ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: isApproved ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade100, 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: isApproved ? Colors.greenAccent : Colors.orange, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            isApproved ? 'Approved — Action Required' : app.status.name.toUpperCase(), 
                            style: TextStyle(color: isApproved ? Colors.white : Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600)
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(app.propertyTitle, style: TextStyle(color: isApproved ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Submitted on ${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year}', style: TextStyle(color: isApproved ? Colors.white70 : Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    if (isApproved) ...[
                      ElevatedButton.icon(
                        onPressed: () => context.push('/tenant/lease/${app.id}'),
                        icon: const Icon(Icons.draw, size: 18),
                        label: const Text('Sign Lease Agreement'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
