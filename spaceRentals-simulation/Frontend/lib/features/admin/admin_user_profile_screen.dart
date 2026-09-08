import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/ui_helpers.dart';
import '../../providers/admin_users_provider.dart';
import '../../providers/di_providers.dart';

class AdminUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const AdminUserProfileScreen({required this.userId, super.key});

  @override
  ConsumerState<AdminUserProfileScreen> createState() =>
      _AdminUserProfileScreenState();
}

class _AdminUserProfileScreenState
    extends ConsumerState<AdminUserProfileScreen> {
  bool _updating = false;

  Future<void> _setStatus(bool active) async {
    setState(() => _updating = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setUserStatus(widget.userId, active);
      ref.invalidate(adminUserProfileProvider(widget.userId));
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        context.showSuccessToast(
          active ? 'Account activated' : 'Account suspended',
        );
      }
    } catch (error) {
      if (mounted) context.showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(adminUserProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load profile: $error')),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.indigo.shade50,
              child: Text(
                profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
                style: TextStyle(fontSize: 28, color: Colors.indigo.shade700),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                profile.email,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            _statusBadge(profile.status),
            const SizedBox(height: 20),
            _section('Account Details', [
              _row('Role', profile.role),
              _row('Phone', profile.phone ?? 'Not provided'),
              _row('Bio', profile.bio ?? 'Not provided'),
              _row('Created', _formatDate(profile.createdAt)),
              _row('Updated', _formatDate(profile.updatedAt)),
            ]),
            const SizedBox(height: 16),
            _section('Security', [
              _row(
                'Two-factor authentication',
                profile.twoFactorEnabled ? 'Enabled' : 'Disabled',
              ),
              _row(
                'Push notifications',
                profile.pushNotificationsEnabled ? 'Enabled' : 'Disabled',
              ),
            ]),
            const SizedBox(height: 24),
            if (_updating)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: () => _setStatus(profile.status == 'suspended'),
                icon: Icon(
                  profile.status == 'suspended' ? Icons.lock_open : Icons.block,
                ),
                label: Text(
                  profile.status == 'suspended'
                      ? 'Activate account'
                      : 'Suspend account',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: profile.status == 'suspended'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) => Center(
    child: Chip(
      label: Text(status.toUpperCase()),
      avatar: Icon(
        status == 'active' ? Icons.check_circle : Icons.warning,
        color: status == 'active' ? Colors.green : Colors.orange,
      ),
      backgroundColor: (status == 'active' ? Colors.green : Colors.orange)
          .withValues(alpha: 0.1),
    ),
  );

  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );

  String _formatDate(DateTime? date) => date == null
      ? 'Not available'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
