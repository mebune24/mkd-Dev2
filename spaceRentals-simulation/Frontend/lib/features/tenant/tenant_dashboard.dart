import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/domain_providers.dart';
import '../../providers/applications_provider.dart';
import '../../shared/models/enums.dart';
import '../../features/rentals/domain/rental.dart';
import '../../widgets/guest_guard.dart';
import 'discover_feed.dart';
import '../../core/utils/currency_formatter.dart';
import 'favorites_screen.dart';
import '../messages/chat_screens.dart';
import '../profile/profile_screen.dart';
import '../../widgets/logo_watermark.dart';
import '../../providers/locale_provider.dart';

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
      const DiscoverFeedScreen(),
      const FavoritesScreen(),
      const MessagesScreen(),
      _MyRentals(tenantId: user.session?.userId),
      const ProfileScreen(),
    ];
  }

  void _showTenantQuickActions() {
    final isFr = ref.read(localeProvider).languageCode == 'fr';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isFr ? 'Actions rapides' : 'Quick actions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _QuickActionTile(
                  icon: Icons.home_work_outlined,
                  color: Colors.green,
                  label: isFr ? 'Publier ma propriété' : 'List my property',
                  subtitle: isFr
                      ? 'Inscription landlord et KYC'
                      : 'Landlord onboarding and KYC',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/landlord/kyc');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.auto_awesome,
                  color: Colors.purple,
                  label: 'SpaceBot',
                  subtitle: isFr
                      ? 'Conseils sur les biens et loyers'
                      : 'Property and rental guidance',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/chatbot');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.real_estate_agent_outlined,
                  color: Colors.orange,
                  label: isFr ? 'Devenir agent' : 'Become an agent',
                  subtitle: isFr
                      ? 'Gagnez des commissions'
                      : 'Earn commissions and grow your network',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/agent/onboarding');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.search_rounded,
                  color: Colors.blue,
                  label: isFr ? 'Explorer les annonces' : 'Browse listings',
                  subtitle: isFr
                      ? 'Voir les biens par catégorie et lieu'
                      : 'View properties by category and location',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/tenant/search');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';
    const navBgColor = Colors.white;
    final navUnselectedColor = Colors.grey.shade600;
    final navSelectedColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _TenantDrawer(user: ref.read(authProvider), isFrench: isFr),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          if (_currentIndex != 0 && _currentIndex != 4) const LogoWatermark(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton(
          heroTag: 'tenant_search_fab',
          onPressed: () => GuestGuard.check(
            context,
            ref,
            _showTenantQuickActions,
            featureName: 'property access',
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          tooltip: isFr ? 'Actions rapides' : 'Quick actions',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle_fill,
                  label: isFr ? 'Découvrir' : 'Discover',
                  index: 0,
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  selectedColor: navSelectedColor,
                  unselectedColor: navUnselectedColor,
                ),
                _NavItem(
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite_rounded,
                  label: isFr ? 'Favoris' : 'Saved',
                  index: 1,
                  currentIndex: _currentIndex,
                  onTap: (i) => GuestGuard.check(
                    context,
                    ref,
                    () => setState(() => _currentIndex = i),
                    featureName: 'saved properties',
                  ),
                  selectedColor: navSelectedColor,
                  unselectedColor: navUnselectedColor,
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: isFr ? 'Messages' : 'Inbox',
                  index: 2,
                  currentIndex: _currentIndex,
                  onTap: (i) => GuestGuard.check(
                    context,
                    ref,
                    () => setState(() => _currentIndex = i),
                    featureName: 'messages',
                  ),
                  selectedColor: navSelectedColor,
                  unselectedColor: navUnselectedColor,
                ),
                _NavItem(
                  icon: Icons.grid_view,
                  activeIcon: Icons.grid_view_rounded,
                  label: isFr ? 'Mon espace' : 'My Space',
                  index: 3,
                  currentIndex: _currentIndex,
                  onTap: (i) => GuestGuard.check(
                    context,
                    ref,
                    () => setState(() => _currentIndex = i),
                    featureName: 'your rentals',
                  ),
                  selectedColor: navSelectedColor,
                  unselectedColor: navUnselectedColor,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: isFr ? 'Profil' : 'Profile',
                  index: 4,
                  currentIndex: _currentIndex,
                  onTap: (i) => GuestGuard.check(
                    context,
                    ref,
                    () => setState(() => _currentIndex = i),
                    featureName: 'profile',
                  ),
                  selectedColor: navSelectedColor,
                  unselectedColor: navUnselectedColor,
                ),
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
  final Color selectedColor;
  final Color unselectedColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? activeIcon : icon,
              key: ValueKey(isActive),
              color: isActive ? selectedColor : unselectedColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hamburger Drawer for Tenant dashboard
class _TenantDrawer extends ConsumerWidget {
  final dynamic user;
  final bool isFrench;
  const _TenantDrawer({required this.user, required this.isFrench});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rentalsAsync = ref.watch(tenantRentalsProvider);
    final monthlyRent = rentalsAsync.maybeWhen(
      data: (rentals) => rentals
          .where((rental) => rental.status.name == 'active')
          .fold<double>(
            0,
            (sum, rental) => sum + rental.monthlyRent.minorUnits.toDouble(),
          ),
      orElse: () => 0.0,
    );

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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.session?.fullName ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user?.session?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CurrencyFormatter.formatCFA(monthlyRent),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
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
                  label: isFrench
                      ? 'Portefeuille & Gains'
                      : 'Wallet & Earnings',
                  subtitle: isFrench
                      ? 'Solde, parrainage & cashout'
                      : 'Balance, referral & cashout',
                  onTap: () {
                    Navigator.pop(context);
                    GuestGuard.check(
                      context,
                      ref,
                      () => context.push('/tenant/monetization'),
                      featureName: 'wallet & earnings',
                    );
                  },
                ),
                _DrawerTile(
                  icon: Icons.handshake,
                  color: Colors.orange,
                  label: isFrench ? 'Micro-Tâches' : 'Micro-tasks',
                  subtitle: isFrench
                      ? 'Gagnez en aidant votre communauté'
                      : 'Earn by helping your community',
                  onTap: () {
                    Navigator.pop(context);
                    GuestGuard.check(
                      context,
                      ref,
                      () => context.push('/tenant/gigs'),
                      featureName: 'micro-gigs',
                    );
                  },
                ),
                _DrawerTile(
                  icon: Icons.real_estate_agent,
                  color: const Color(0xFF6A1B9A),
                  label: isFrench ? 'Devenir Agent' : 'Become an Agent',
                  subtitle: isFrench
                      ? 'Gagnez des commissions de location'
                      : 'Earn rental commissions',
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
                  label: isFrench ? 'Notifications' : 'Notifications',
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
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
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
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.key_off,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Rentals Available',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please log in or create an account to view and manage your rentals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Sign In to View Rentals',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final applicationsAsync = ref.watch(tenantApplicationsProvider);
    final rentalsAsync = ref.watch(tenantRentalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Rentals & Applications'),
        foregroundColor: const Color(0xFF303030),
        elevation: 0,
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load rentals: $e')),
        data: (applications) {
          final List<Rental> rentals = rentalsAsync.maybeWhen(
            data: (value) => value,
            orElse: () => const <Rental>[],
          );
          if (applications.isEmpty && rentals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rentals yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start by searching for properties and applying.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rentals.length + applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index < rentals.length) {
                final rental = rentals[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        const Color(0xFF5D3F6A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE RENTAL',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        rental.propertyTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monthly rent: ${CurrencyFormatter.formatCFA(rental.monthlyRent.minorUnits.toDouble())}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/tenant/maintenance'),
                        icon: const Icon(Icons.build_outlined),
                        label: const Text('Maintenance'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final app = applications[index - rentals.length];
              final isApproved = app.status == ApplicationStatus.approved;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isApproved
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            const Color(0xFF5D3F6A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isApproved ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isApproved
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: isApproved
                                ? Colors.greenAccent
                                : Colors.orange,
                            size: 8,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isApproved
                                ? 'Approved — Action Required'
                                : app.status.name.toUpperCase(),
                            style: TextStyle(
                              color: isApproved
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      app.propertyTitle,
                      style: TextStyle(
                        color: isApproved ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted on ${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year}',
                      style: TextStyle(
                        color: isApproved ? Colors.white70 : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isApproved) ...[
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/tenant/lease/${app.id}'),
                        icon: const Icon(Icons.draw, size: 18),
                        label: const Text('Sign Lease Agreement'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
