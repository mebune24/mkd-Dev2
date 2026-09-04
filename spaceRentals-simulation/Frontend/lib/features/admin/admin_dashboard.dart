import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/di_providers.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import '../profile/profile_screen.dart';
import 'audit_logs_screen.dart';
import 'reports_screen.dart';
import '../../core/utils/ui_helpers.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _AdminOverviewScreen(),
    const ReportsScreen(),
    const AuditLogsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Overview', index: 0, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Reports', index: 1, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history_rounded, label: 'Audit Log', index: 2, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', index: 3, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, currentIndex;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? activeIcon : icon, color: isActive ? theme.colorScheme.primary : Colors.grey, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? theme.colorScheme.primary : Colors.grey)),
        ]),
      ),
    );
  }
}

// ── Admin Overview Screen ────────────────────────────────────────────────────

class _AdminOverviewScreen extends ConsumerWidget {
  const _AdminOverviewScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(authProvider);
    final theme = Theme.of(context);
    final allUsersAsync = ref.watch(allUsersProvider);
    final kycListAsync = ref.watch(kycSubmissionsProvider);
    final disputesAsync = ref.watch(disputesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: allUsersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading users: $e')),
        data: (allUsers) => kycListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading KYC: $e')),
          data: (kycList) => disputesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading disputes: $e')),
            data: (disputes) {
              final tenants = allUsers.where((u) => u.role == Role.tenant).toList();
              final landlords = allUsers.where((u) => u.role == Role.landlord).toList();
              final admins = allUsers.where((u) => u.role == Role.admin).toList();
              final pendingKYC = kycList.where((k) => k.status == 'pending').toList();
              final openDisputes = disputes.where((d) => d.status == 'open').toList();

              return CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0033), Color(0xFF5D3F6A)],
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
                        const Row(
                          children: [
                            Icon(Icons.shield_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 6),
                            Text('Admin Portal', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Welcome, ${admin.session?.fullName ?? 'Admin'} 👋',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${allUsers.length} total users · ${pendingKYC.length} pending KYC · ${openDisputes.length} open disputes',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
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
                  // ── Stats Grid ──────────────────────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(value: '${allUsers.length}', label: 'Total Users', icon: Icons.people_rounded, color: theme.colorScheme.primary, onTap: () => context.go('/admin/users')),
                      _StatCard(value: '${tenants.length}', label: 'Tenants', icon: Icons.home_rounded, color: Colors.teal, onTap: () => context.go('/admin/tenants')),
                      _StatCard(value: '${landlords.length}', label: 'Landlords', icon: Icons.business_rounded, color: Colors.indigo, onTap: () => context.go('/admin/landlords')),
                      _StatCard(value: '${pendingKYC.length}', label: 'Pending KYC', icon: Icons.pending_actions_rounded, color: Colors.orange, alert: pendingKYC.isNotEmpty, onTap: () => context.go('/admin/kyc')),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── KYC Management ─────────────────────────────────────────
                  _SectionHeader(
                    title: 'KYC Verification',
                    subtitle: '${pendingKYC.length} awaiting review',
                    icon: Icons.verified_user_rounded,
                    color: Colors.orange,
                    badge: pendingKYC.length,
                  ),
                  const SizedBox(height: 12),
                  if (pendingKYC.isEmpty)
                    const _EmptyState(icon: Icons.check_circle_outline, message: 'No pending KYC submissions', color: Colors.green)
                  else
                    ...pendingKYC.take(3).map((sub) => _KYCCard(submission: sub, ref: ref, theme: theme)),
                  if (pendingKYC.length > 3)
                    _ViewAllButton(label: 'View all ${pendingKYC.length} KYC submissions', onTap: () => _showKYCBottomSheet(context, ref, kycList)),
                  if (pendingKYC.isNotEmpty && pendingKYC.length <= 3)
                    _ViewAllButton(label: 'View all KYC submissions', onTap: () => _showKYCBottomSheet(context, ref, kycList)),
                  const SizedBox(height: 28),

                  // ── Disputes ────────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Disputes',
                    subtitle: '${openDisputes.length} open cases',
                    icon: Icons.gavel_rounded,
                    color: Colors.red,
                    badge: openDisputes.length,
                  ),
                  const SizedBox(height: 12),
                  if (disputes.isEmpty)
                    const _EmptyState(icon: Icons.handshake_outlined, message: 'No disputes filed yet', color: Colors.green)
                  else
                    ...disputes.take(3).map((d) => _DisputeCard(dispute: d, ref: ref, theme: theme)),
                  if (disputes.length > 3)
                    _ViewAllButton(label: 'View all ${disputes.length} disputes', onTap: () => _showDisputesBottomSheet(context, ref, disputes)),
                  const SizedBox(height: 28),

                  // ── User Management ─────────────────────────────────────────
                  _SectionHeader(
                    title: 'User Management',
                    subtitle: '${allUsers.length} registered accounts',
                    icon: Icons.manage_accounts_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _ManagementTile(
                    icon: Icons.person_add_alt_1_rounded,
                    color: theme.colorScheme.primary,
                    title: 'Add Administrator',
                    subtitle: 'Grant admin access to a new user',
                    onTap: () => _showAddAdminDialog(context, ref, theme),
                  ),
                  const SizedBox(height: 10),
                  _ManagementTile(
                    icon: Icons.people_rounded,
                    color: Colors.indigo,
                    title: 'View All Users',
                    subtitle: '${tenants.length} tenants · ${landlords.length} landlords · ${admins.length} admins',
                    onTap: () => _showUsersBottomSheet(context, ref, allUsers, theme),
                  ),
                  const SizedBox(height: 10),
                  _ManagementTile(
                    icon: Icons.real_estate_agent_rounded,
                    color: Colors.teal,
                    title: 'Manage Agents',
                    subtitle: 'Approve and monitor Agents',
                    onTap: () => context.push('/admin/agents'),
                  ),
                  const SizedBox(height: 10),
                  _ManagementTile(
                    icon: Icons.delete_sweep_rounded,
                    color: Colors.red,
                    title: 'Remove Test Accounts',
                    subtitle: 'Clean up test/dummy accounts from platform',
                    onTap: () => _showRemoveTestDialog(context, ref, allUsers, theme),
                  ),
                  const SizedBox(height: 28),

                  // ── Admins List ─────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Administrators',
                    subtitle: '${admins.length} active admins',
                    icon: Icons.shield_rounded,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  ...admins.map((a) => _AdminCard(admin: a, currentAdminId: admin.session?.userId ?? '', ref: ref, theme: theme)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      );
    })))
    );
  }

  void _showKYCBottomSheet(BuildContext context, WidgetRef ref, List<KYCSubmission> submissions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Icon(Icons.verified_user_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('All KYC Submissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: submissions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _KYCCard(submission: submissions[i], ref: ref, theme: Theme.of(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisputesBottomSheet(BuildContext context, WidgetRef ref, List<DisputeRecord> disputes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Icon(Icons.gavel_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Text('All Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: disputes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _DisputeCard(dispute: disputes[i], ref: ref, theme: Theme.of(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUsersBottomSheet(BuildContext context, WidgetRef ref, List<UserModel> users, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Icon(Icons.manage_accounts_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('All Users (${users.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final u = users[i];
                    final roleColor = u.role == Role.admin ? Colors.purple : u.role == Role.landlord ? Colors.indigo : Colors.teal;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: roleColor.withValues(alpha: 0.12),
                        child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(u.email, style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(u.role.name, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context, WidgetRef ref, ThemeData theme) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.person_add_alt_1_rounded, color: Colors.purple),
          SizedBox(width: 10),
          Text('Add Administrator'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              try {
                final currentAuth = ref.read(authProvider);
                final newAdmin = UserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  email: emailCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  role: Role.admin,
                  status: 'active',
                  kycStatus: 'verified',
                );
                // ref.read(allUsersProvider.notifier).addAdmin(newAdmin);
                // ref.read(auditLogProvider.notifier).log(
                  currentAuth.session?.userId ?? 'admin',
                  currentAuth.session?.fullName ?? 'Admin',
                  'Added new admin: ${newAdmin.name}',
                );
                Navigator.pop(ctx);
                context.showSuccessToast('Admin ${newAdmin.name} added successfully');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
              }
            },
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  void _showRemoveTestDialog(BuildContext context, WidgetRef ref, List<UserModel> users, ThemeData theme) {
    final testAccounts = users.where((u) => u.email.contains('test') || u.email.contains('dummy') || u.email.contains('mock') || u.name.toLowerCase().contains('test')).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.delete_sweep_rounded, color: Colors.red),
          SizedBox(width: 10),
          Text('Remove Test Accounts'),
        ]),
        content: testAccounts.isEmpty
            ? const Text('No test accounts detected.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Found ${testAccounts.length} test account(s):', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...testAccounts.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${u.name} (${u.email})', style: const TextStyle(fontSize: 13)),
                  )),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          if (testAccounts.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                for (final u in testAccounts) {
                  // ref.read(allUsersProvider.notifier).removeUser(u.id);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${testAccounts.length} test account(s) removed'), backgroundColor: Colors.orange));
              },
              child: const Text('Remove All'),
            ),
        ],
      ),
    );
  }
}

// ── KYC Card ─────────────────────────────────────────────────────────────────

class _KYCCard extends ConsumerWidget {
  final KYCSubmission submission;
  final WidgetRef ref;
  final ThemeData theme;
  const _KYCCard({required this.submission, required this.ref, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = submission.status == 'approved' ? Colors.green : submission.status == 'rejected' ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: submission.status == 'pending' ? Colors.orange.withValues(alpha: 0.3) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: Text(submission.userName.isNotEmpty ? submission.userName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(submission.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(submission.userEmail, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(submission.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(submission.isPremium ? Icons.star_rounded : Icons.verified_user_outlined, size: 14, color: submission.isPremium ? Colors.amber : Colors.blue),
              const SizedBox(width: 4),
              Text(submission.isPremium ? 'Premium KYC' : 'Basic KYC', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Submitted: ${_formatDate(submission.submittedAt)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          if (submission.documents.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Uploaded Documents:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: submission.documents.entries.map((entry) => GestureDetector(
                onTap: () => _showDocumentFullscreen(context, entry.value),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: FileImage(File(entry.value)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.key, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600)),
                  ],
                ),
              )).toList(),
            ),
          ],
          if (submission.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    onPressed: () {
                      final admin = ref.read(authProvider);
                      // ref.read(kycSubmissionsProvider.notifier).reject(
                      //       submission.userId,
                      //       adminId: admin.session?.userId ?? 'admin',
                      //       adminName: admin.session?.fullName ?? 'Admin',
                      //     );
                      context.showErrorToast('KYC Rejected');
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () {
                      final admin = ref.read(authProvider);
                      // ref.read(kycSubmissionsProvider.notifier).approve(
                      //       submission.userId,
                      //       premium: submission.isPremium,
                      //       adminId: admin.session?.userId ?? 'admin',
                      //       adminName: admin.session?.fullName ?? 'Admin',
                      //     );
                      context.showSuccessToast('KYC Approved');
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  void _reject(BuildContext context, WidgetRef ref, KYCSubmission sub) {
    // ref.read(kycSubmissionsProvider.notifier).reject(sub.userId);
    // ref.read(allUsersProvider.notifier).updateUserKYC(sub.userId, 'rejected');
    // ref.read(auditLogProvider.notifier).log(
    //   ref.read(authProvider).session?.userId ?? 'admin',
    //   ref.read(authProvider).session?.fullName ?? 'Admin',
    //   'Rejected KYC for ${sub.userName}',
    // );
    context.showErrorToast('KYC Rejected ❌');
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showDocumentFullscreen(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dispute Card ──────────────────────────────────────────────────────────────

class _DisputeCard extends StatelessWidget {
  final DisputeRecord dispute;
  final WidgetRef ref;
  final ThemeData theme;
  const _DisputeCard({required this.dispute, required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    final statusColor = dispute.status == 'resolved' ? Colors.green : dispute.status == 'under_review' ? Colors.blue : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dispute.status == 'open' ? Colors.red.withValues(alpha: 0.3) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.gavel_rounded, color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dispute.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Filed by ${dispute.filedByName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(dispute.status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(dispute.description, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (dispute.status != 'resolved') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (dispute.status == 'open')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final admin = ref.read(authProvider);
                        // ref.read(disputesProvider.notifier).setUnderReview(
                        //       dispute.id,
                        //       adminId: admin.session?.userId ?? 'admin',
                        //       adminName: admin.session?.fullName ?? 'Admin',
                        //       subject: dispute.subject,
                        //     );
                      },
                      icon: const Icon(Icons.search, size: 14),
                      label: const Text('Review', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (dispute.status == 'open') const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () => _resolveDispute(context, dispute),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Resolve', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
          if (dispute.resolution != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.withValues(alpha: 0.2))),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                const SizedBox(width: 6),
                Expanded(child: Text('Resolution: ${dispute.resolution}', style: const TextStyle(color: Colors.green, fontSize: 12))),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  void _resolveDispute(BuildContext context, DisputeRecord d) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Resolution note', hintText: 'Describe how this was resolved...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final admin = ref.read(authProvider);
              // ref.read(disputesProvider.notifier).resolve(
                    d.id,
                    ctrl.text.trim().isEmpty ? 'Resolved by admin' : ctrl.text.trim(),
                    adminId: admin.session?.userId ?? 'admin',
                    adminName: admin.session?.fullName ?? 'Admin',
                    subject: d.subject,
                  );
              Navigator.pop(ctx);
              context.showSuccessToast('Dispute resolved ✅');
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

// ── Admin Card ────────────────────────────────────────────────────────────────

class _AdminCard extends StatelessWidget {
  final UserModel admin;
  final String currentAdminId;
  final WidgetRef ref;
  final ThemeData theme;
  const _AdminCard({required this.admin, required this.currentAdminId, required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isSelf = admin.id == currentAdminId;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelf ? Colors.purple.withValues(alpha: 0.3) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.purple.withValues(alpha: 0.1),
            child: Text(admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (isSelf) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Text('You', style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                Text(admin.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.shield_rounded, color: Colors.purple, size: 20),
        ],
      ),
    );
  }
}

// ── Shared UI Widgets ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final bool alert;
  final VoidCallback? onTap;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color, this.alert = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alert ? color.withValues(alpha: 0.4) : Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              if (alert)
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
              FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final int badge;
  const _SectionHeader({required this.title, required this.subtitle, required this.icon, required this.color, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (badge > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _EmptyState({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ManagementTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
            Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Colors.grey, size: 16)),
          ],
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ViewAllButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
