import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/domain_providers.dart';
import '../../core/utils/ui_helpers.dart';
import '../../../core/utils/ui_helpers.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  Color _roleColor(Role role) {
    switch (role) {
      case Role.admin:
        return Colors.deepPurple;
      case Role.landlord:
        return Colors.blue;
      case Role.tenant:
        return Colors.teal;
      case Role.agent:
        return Colors.orange;
    }
  }

  void _toggleSuspend(BuildContext context, WidgetRef ref, UserModel current) {
    // In a real app we'd call a provider method here.
    context.showSuccessToast('User status updated.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (usersList) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: usersList.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = usersList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _roleColor(user.role).withValues(alpha: 0.15),
                child: Icon(
                  user.role == Role.admin
                      ? Icons.admin_panel_settings
                      : user.role == Role.landlord
                          ? Icons.business
                          : user.role == Role.agent
                              ? Icons.real_estate_agent
                              : Icons.person,
                  color: _roleColor(user.role),
                ),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor(user.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: _roleColor(user.role), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.status == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: user.status == 'active' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: user.role != Role.admin
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'toggle') _toggleSuspend(context, ref, user);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(user.status == 'active' ? 'Suspend User' : 'Restore User'),
                        ),
                      ],
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
