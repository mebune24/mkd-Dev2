import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/admin_users_provider.dart';

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(adminUsersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F0F7),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading admins: $e'),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminUsersProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
        data: (users) {
          final admins = users.where((u) => u.role == Role.admin).toList();
          
          if (admins.isEmpty) {
            return const Center(child: Text('No administrators found.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final admin = admins[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary),
                  ),
                  title: Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(admin.email),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
