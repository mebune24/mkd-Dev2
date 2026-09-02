import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/di_providers.dart';
import '../../core/utils/ui_helpers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  // ── Avatar picker ──────────────────────────────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60, maxWidth: 512);
      if (image == null) return;

      setState(() => _isSaving = true);
      final bytes = await File(image.path).readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final repo = ref.read(authRepositoryProvider);
      await repo.updateProfile(avatarUrl: base64Str);
      await ref.read(authProvider.notifier).updateSessionProfile(avatarUrl: base64Str);

      if (mounted) context.showToast('Profile picture updated ✓');
    } catch (e) {
      if (mounted) context.showErrorToast('Failed to update picture: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Edit name dialog ───────────────────────────────────────────────────────
  Future<void> _showEditNameDialog() async {
    final user = ref.read(authProvider).session;
    if (user == null) return;
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: firstCtrl,
            decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastCtrl,
            decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final fn = firstCtrl.text.trim();
              final ln = lastCtrl.text.trim();
              if (fn.isEmpty) return;
              setState(() => _isSaving = true);
              try {
                final repo = ref.read(authRepositoryProvider);
                await repo.updateProfile(firstName: fn, lastName: ln);
                await ref.read(authProvider.notifier).updateSessionProfile(firstName: fn, lastName: ln);
                if (mounted) context.showToast('Name updated ✓');
              } catch (e) {
                if (mounted) context.showErrorToast('Failed: $e');
              } finally {
                if (mounted) setState(() => _isSaving = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Edit phone dialog ──────────────────────────────────────────────────────
  Future<void> _showEditPhoneDialog() async {
    final user = ref.read(authProvider).session;
    final ctrl = TextEditingController(text: user?.phone ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Phone Number'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+237 6XX XXX XXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final phone = ctrl.text.trim();
              if (phone.isEmpty) return;
              setState(() => _isSaving = true);
              try {
                final repo = ref.read(authRepositoryProvider);
                await repo.updateProfile(phone: phone);
                await ref.read(authProvider.notifier).updateSessionProfile(phone: phone);
                if (mounted) context.showToast('Phone updated ✓');
              } catch (e) {
                if (mounted) context.showErrorToast('Failed: $e');
              } finally {
                if (mounted) setState(() => _isSaving = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Change password dialog ─────────────────────────────────────────────────
  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                  ),
                ),
                obscureText: obscureCurrent,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                  ),
                ),
                obscureText: obscureNew,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
                obscureText: obscureConfirm,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (newCtrl.text.length < 6) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() => _isSaving = true);
                try {
                  final repo = ref.read(authRepositoryProvider);
                  await repo.changePassword(currentCtrl.text, newCtrl.text);
                  if (mounted) context.showToast('Password changed successfully ✓');
                } catch (e) {
                  if (mounted) context.showErrorToast('Failed: $e');
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle helpers ─────────────────────────────────────────────────────────
  Future<void> _toggleTwoFA(bool val) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateProfile(twoFactorEnabled: val);
      await ref.read(authProvider.notifier).updateSessionProfile(twoFactorEnabled: val);
    } catch (e) {
      if (mounted) context.showErrorToast('Failed to update 2FA');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleNotifications(bool val) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateProfile(pushNotificationsEnabled: val);
      await ref.read(authProvider.notifier).updateSessionProfile(pushNotificationsEnabled: val);
    } catch (e) {
      if (mounted) context.showErrorToast('Failed to update notifications');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.session;
    final locale = ref.watch(localeProvider);
    final isFrench = locale.languageCode == 'fr';
    final theme = Theme.of(context);

    // ── Guest / unauthenticated view ──────────────────────────────────────────
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
                Icon(Icons.person_outline, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                const SizedBox(height: 24),
                Text(isFrench ? 'Profil Invité' : 'Guest Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  isFrench
                      ? 'Créez un compte pour gérer votre profil et vos paramètres.'
                      : 'Create an account to manage your profile and settings.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.go('/register'),
                  child: Text(isFrench ? 'Créer un compte' : 'Create Account'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(isFrench ? 'Se connecter' : 'Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Authenticated view ────────────────────────────────────────────────────
    final String initials = (user.fullName.trim().isNotEmpty)
        ? user.fullName.trim().substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header / Avatar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              backgroundImage: user.avatarUrl != null
                                  ? (user.avatarUrl!.startsWith('data:image')
                                      ? MemoryImage(base64Decode(user.avatarUrl!.split(',').last))
                                      : NetworkImage(user.avatarUrl!) as ImageProvider)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(initials,
                                      style: const TextStyle(
                                          fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                                ),
                                child: Icon(Icons.camera_alt, size: 17, color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(user.fullName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Personal Info ────────────────────────────────────
                      _sectionTitle(isFrench ? 'Informations personnelles' : 'Personal Information', theme),
                      _card(children: [
                        _listTile(
                          icon: Icons.person_outline,
                          title: isFrench ? 'Nom complet' : 'Full Name',
                          subtitle: user.fullName,
                          trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                          onTap: _showEditNameDialog,
                        ),
                        const Divider(height: 1, indent: 56),
                        _listTile(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          subtitle: user.email,
                          // Email is managed by auth — read-only
                        ),
                        const Divider(height: 1, indent: 56),
                        _listTile(
                          icon: Icons.phone_outlined,
                          title: isFrench ? 'Téléphone' : 'Phone Number',
                          subtitle: user.phone?.isNotEmpty == true
                              ? user.phone!
                              : (isFrench ? 'Appuyez pour ajouter' : 'Tap to add'),
                          trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
                          onTap: _showEditPhoneDialog,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Earn & Save (tenant only) ────────────────────────
                      if (user.role.name == 'tenant') ...[
                        _sectionTitle('Earn & Save', theme),
                        _card(children: [
                          _listTile(
                            icon: Icons.share,
                            title: 'SpaceReferral Bonus',
                            subtitle: 'Earn 15,000 F CFA per invited friend',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () => context.push('/tenant/monetization'),
                          ),
                          const Divider(height: 1, indent: 56),
                          _listTile(
                            icon: Icons.star,
                            title: 'Top Ratings Bonus',
                            subtitle: 'Bonus when your score exceeds 4.8★',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: const Text('4.8 ★',
                                  style: TextStyle(
                                      color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          _listTile(
                            icon: Icons.handshake,
                            title: 'Community Micro-Tasks',
                            subtitle: 'Accept missions near you',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () => context.push('/tenant/gigs'),
                          ),
                        ]),
                        const SizedBox(height: 20),
                      ],

                      // ── Security ─────────────────────────────────────────
                      _sectionTitle(isFrench ? 'Sécurité' : 'Security', theme),
                      _card(children: [
                        _listTile(
                          icon: Icons.lock_outline,
                          title: isFrench ? 'Changer le mot de passe' : 'Change Password',
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: _showChangePasswordDialog,
                        ),
                        const Divider(height: 1, indent: 56),
                        _switchTile(
                          icon: Icons.security,
                          title: isFrench ? 'Double authentification' : 'Two-Factor Auth',
                          value: user.twoFactorEnabled,
                          onChanged: _toggleTwoFA,
                          theme: theme,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Preferences ──────────────────────────────────────
                      _sectionTitle(isFrench ? 'Préférences' : 'Preferences', theme),
                      _card(children: [
                        _switchTile(
                          icon: Icons.notifications_outlined,
                          title: isFrench ? 'Notifications' : 'Push Notifications',
                          value: user.pushNotificationsEnabled,
                          onChanged: _toggleNotifications,
                          theme: theme,
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF0EDF5),
                            child: Icon(Icons.language, color: Colors.purple),
                          ),
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
                                    style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
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

                      // ── Logout ───────────────────────────────────────────
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(isFrench ? 'Se déconnecter' : 'Log Out'),
                              content: Text(isFrench 
                                  ? 'Êtes-vous sûr de vouloir vous déconnecter ?' 
                                  : 'Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(isFrench ? 'Annuler' : 'Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text(isFrench ? 'Oui, me déconnecter' : 'Yes, log out', style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(authProvider.notifier).signOut();
                            if (mounted) context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(isFrench ? 'Se déconnecter' : 'Log Out'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Global saving overlay ──────────────────────────────────────────
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Saving...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 0.8)),
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
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        trailing: trailing,
        onTap: onTap,
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) =>
      ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0EDF5),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: _isSaving ? null : onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      );
}
