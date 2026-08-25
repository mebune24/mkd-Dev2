import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/ui_helpers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _twoFAEnabled = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated locally.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _showEditNameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.showToast('Name updated successfully.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()), obscureText: true),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'New Password', border: OutlineInputBorder()), obscureText: true),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.showToast('Password changed successfully.');
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final isFrench = locale.languageCode == 'fr';
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                Text(
                  isFrench ? 'Profil Invité' : 'Guest Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  isFrench
                      ? 'Créez un compte pour gérer votre profil et vos paramètres.'
                      : 'Create an account to manage your profile and settings.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.go('/register'),
                  child: Text(isFrench ? 'Créer un compte' : 'Create Account', style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(isFrench ? 'Se connecter' : 'Sign In', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? Text(
                                (user.session?.fullName ?? '?').substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                            ),
                            child: Icon(Icons.camera_alt, size: 18, color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(user.session?.fullName ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.session?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user.session?.role.name ?? 'user').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Personal Info ──────────────────────────────
                  _sectionTitle(isFrench ? 'Informations personnelles' : 'Personal Information', theme),
                  _card(children: [
                    _listTile(
                      icon: Icons.person_outline,
                      title: isFrench ? 'Nom complet' : 'Full Name',
                      subtitle: user.session?.fullName ?? 'Unknown',
                      trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onTap: () => _showEditNameDialog(user.session?.fullName ?? ''),
                    ),
                    const Divider(height: 1, indent: 56),
                    _listTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: user.session?.email ?? '',
                    ),
                    const Divider(height: 1, indent: 56),
                    _listTile(
                      icon: Icons.phone_outlined,
                      title: isFrench ? 'Téléphone' : 'Phone Number',
                      subtitle: '+237 600 000 000',
                      trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone update requires backend integration.')),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Earn & Save ─────────────────────────────────
                  if (user.session?.role.name == 'tenant') ...[
                    _sectionTitle('Earn & Save', theme),
                    _card(children: [
                      _listTile(
                        icon: Icons.share,
                        title: 'SpaceReferral Bonus',
                        subtitle: 'Gagnez 15 000 F CFA par ami invité',
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.push('/tenant/monetization'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _listTile(
                        icon: Icons.star,
                        title: 'Top Ratings Bonus',
                        subtitle: 'Recevez un bonus quand votre score dépasse 4.8★',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: const Text('4.8 ★', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Maintenez votre note pour débloquer le bonus Top Ratings!')),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _listTile(
                        icon: Icons.handshake,
                        title: 'Micro-Tâches communautaires',
                        subtitle: 'Acceptez des missions près de chez vous',
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.push('/tenant/gigs'),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // ── Security ─────────────────────────────────────
                  _sectionTitle(isFrench ? 'Sécurité' : 'Security', theme),
                  _card(children: [
                    _listTile(
                      icon: Icons.lock_outline,
                      title: isFrench ? 'Changer le mot de passe' : 'Change Password',
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFF0EDF5), child: Icon(Icons.security, color: Colors.purple)),
                      title: Text(isFrench ? 'Double authentification' : 'Two-Factor Auth'),
                      trailing: Switch(
                        value: _twoFAEnabled,
                        onChanged: (v) => setState(() => _twoFAEnabled = v),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Preferences ────────────────────────────────
                  _sectionTitle(isFrench ? 'Préférences' : 'Preferences', theme),
                  _card(children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFF0EDF5), child: Icon(Icons.notifications_outlined, color: Colors.purple)),
                      title: Text(isFrench ? 'Notifications' : 'Push Notifications'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    // Language toggle
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFF0EDF5), child: Icon(Icons.language, color: Colors.purple)),
                      title: Text(isFrench ? 'Langue' : 'Language'),
                      trailing: GestureDetector(
                        onTap: () => ref.read(localeProvider.notifier).toggle(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(isFrench ? '🇫🇷' : '🇨🇲', style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                isFrench ? 'Français' : 'English',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.swap_horiz, size: 14, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // ── Logout ─────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).signOut();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(isFrench ? 'Se déconnecter' : 'Log Out'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 0.8)),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(children: children),
      );

  Widget _listTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0EDF5),
          child: Icon(icon, color: Colors.purple, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing,
        onTap: onTap,
      );
}
