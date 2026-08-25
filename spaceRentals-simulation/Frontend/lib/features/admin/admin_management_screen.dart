import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/ui_helpers.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  ConsumerState<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  // A mock list since MockAuthService._mockUsers is private.
  // In a real app, this would be fetched from the backend.
  final List<UserModel> _admins = [
    // This is the default root admin, allowing them to login.
    UserModel(
      id: 'root_admin_1',
      email: 'admin@spacerentals.com',
      name: 'Root Admin',
      role: Role.admin,
      status: 'active',
      kycStatus: 'verified',
    )
  ];

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Administrator'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Temporary Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              
              // Add to local UI list
              setState(() {
                _admins.add(UserModel(
                  id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  role: Role.admin,
                  status: 'active',
                  kycStatus: 'verified',
                ));
              });
              
              // Register them in the mock backend so they can actually log in
              final nameParts = nameCtrl.text.trim().split(' ');
              await ref.read(authProvider.notifier).signUp(
                email: emailCtrl.text.trim(),
                password: passCtrl.text,
                firstName: nameParts.isNotEmpty ? nameParts.first : nameCtrl.text.trim(),
                lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
                role: Role.admin.name,
              );
              
              if (mounted) {
                Navigator.pop(context);
                context.showToast('Admin added successfully.');
              }
            },
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(UserModel admin) {
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password for ${admin.name}'),
        content: TextField(
          controller: passCtrl,
          decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.vpn_key)),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (passCtrl.text.isEmpty) return;
              
              // In a real app, this calls an API to update the password.
              // For now, just show a success message.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password changed successfully for ${admin.name}')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3F0F7),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Admin'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _admins.length,
        itemBuilder: (context, index) {
          final admin = _admins[index];
          final isRoot = admin.id == 'root_admin_1';
          
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
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'change_password') {
                    _showChangePasswordDialog(admin);
                  } else if (val == 'remove' && !isRoot) {
                    setState(() {
                      _admins.removeAt(index);
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Row(children: [Icon(Icons.password, size: 20), SizedBox(width: 8), Text('Change Password')]),
                  ),
                  if (!isRoot)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Remove', style: TextStyle(color: Colors.red))]),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
