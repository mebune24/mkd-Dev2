import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Call this before any operation that requires authentication.
/// If the user is a guest, shows a beautiful sign-in prompt modal.
/// If the user is authenticated, calls [action] immediately.
///
/// Usage:
/// ```dart
/// GuestGuard.check(context, ref, () {
///   context.push('/tenant/apply', extra: property);
/// });
/// ```
class GuestGuard {
  static void check(
    BuildContext context,
    WidgetRef ref,
    VoidCallback action, {
    String? featureName,
  }) {
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      action();
    } else {
      _showSignInModal(context, featureName: featureName);
    }
  }

  static void _showSignInModal(
    BuildContext context, {
    String? featureName,
  }) {
    // Capture the GoRouter BEFORE showing the modal.
    // After the modal is shown and then dismissed, the modal's BuildContext
    // is detached from the tree, so calling context.go() from inside the
    // modal widget would fail. Using the captured router reference is safe.
    final router = GoRouter.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (modalCtx) => _GuestSignInModal(
        featureName: featureName,
        onSignIn: () {
          Navigator.of(modalCtx, rootNavigator: true).pop();
          router.go('/login');
        },
        onCreateAccount: () {
          Navigator.of(modalCtx, rootNavigator: true).pop();
          router.go('/register');
        },
        onDismiss: () => Navigator.of(modalCtx, rootNavigator: true).pop(),
      ),
    );
  }
}

class _GuestSignInModal extends StatelessWidget {
  final String? featureName;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onDismiss;

  const _GuestSignInModal({
    this.featureName,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feature = featureName ?? 'this feature';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Lock icon with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'You need an account to access $feature.\nJoin thousands of happy renters on SpaceRentals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          // Benefits row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BenefitChip(Icons.home_rounded, 'Apply for\nProperties', theme),
              _BenefitChip(Icons.favorite_rounded, 'Save\nFavourites', theme),
              _BenefitChip(Icons.chat_bubble_rounded, 'Chat with\nLandlords', theme),
            ],
          ),
          const SizedBox(height: 28),

          // Sign In button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onSignIn,
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Create Account button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: onCreateAccount,
              child: const Text(
                'Create Free Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Continue browsing
          TextButton(
            onPressed: onDismiss,
            child: Text(
              'Continue Browsing',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _BenefitChip(this.icon, this.label, this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 11, color: Colors.grey.shade600, height: 1.3),
        ),
      ],
    );
  }
}
