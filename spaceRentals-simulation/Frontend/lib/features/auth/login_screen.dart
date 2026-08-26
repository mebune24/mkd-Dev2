import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/animated_loading_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/utils/ui_helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'tenant1@spacerentals.cm');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final isFr = ref.read(localeProvider).languageCode == 'fr';
    
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: isFr ? 'Veuillez remplir tous les champs' : 'Please fill all input fields',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: isFr ? 'Veuillez corriger les erreurs de formulaire' : 'Please fix the form errors',
        backgroundColor: Colors.red,
      );
      return;
    }
    
    try {
      final success = await ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      
      final authState = ref.read(authProvider);
      if (success && authState.session != null) {
        final user = authState.session!;
        if (user.role == Role.tenant) { 
          context.go('/tenant'); 
        } else if (user.role == Role.landlord) { 
          // We don't have KYC status in UserSession anymore, that's in UserModel,
          // but for routing purposes, just route to landlord dashboard for now.
          context.go('/landlord');
        } else if (user.role == Role.admin) { 
          context.go('/admin'); 
        } else if (user.role == Role.agent) {
          context.go('/agent'); // Or wherever agents go
        }
      } else if (authState.error != null) {
        Fluttertoast.showToast(msg: authState.error!, backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    }
  }

  void _continueAsGuest() {
    // Signal the authProvider so the goRouter redirect handles navigation
    ref.read(authProvider.notifier).continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isFr = locale.languageCode == 'fr';
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Top wave header ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: size.height * 0.38,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          const Color(0xFF5D3F6A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Language toggle
                  Positioned(
                    top: 50,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isFr ? '🇫🇷' : '🇨🇲',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              isFr ? 'FR' : 'EN',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logo & title
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.apartment_rounded, size: 48, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'SpaceRentals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isFr
                              ? 'Trouvez votre espace idéal'
                              : 'Find your perfect space',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Form card ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isFr ? 'Connexion' : 'Welcome back',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFr
                            ? 'Connectez-vous à votre compte'
                            : 'Sign in to your account',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      _inputField(
                        controller: _emailController,
                        label: isFr ? 'Adresse e-mail' : 'Email address',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isFr ? 'L\'email est requis' : 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return isFr ? 'Email invalide' : 'Invalid email format';
                          }
                          return null;
                        }
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _inputField(
                        controller: _passwordController,
                        label: isFr ? 'Mot de passe' : 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isFr ? 'Le mot de passe est requis' : 'Password is required';
                          }
                          return null;
                        }
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4)),
                          child: Text(
                            isFr ? 'Mot de passe oublié?' : 'Forgot password?',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Sign In button
                      AnimatedLoadingButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          isFr ? 'Se connecter' : 'Sign In',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Continue as Guest (Tenant only)
                      OutlinedButton.icon(
                        onPressed: _continueAsGuest,
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: Text(
                          isFr
                              ? 'Continuer en tant qu\'invité (Locataire)'
                              : 'Continue as Guest (Tenant)',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                  alpha: 0.4)),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Social divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              isFr ? 'ou se connecter avec' : 'or sign in with',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Social logos — horizontal row of colored icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialLogo(
                            onTap: () => _socialSnack('Google'),
                            bgColor: Colors.white,
                            borderColor: Colors.grey.shade200,
                            child: const FaIcon(FontAwesomeIcons.google, color: Color(0xFFDB4437), size: 24),
                          ),
                          const SizedBox(width: 20),
                          _socialLogo(
                            onTap: () => _socialSnack('Facebook'),
                            bgColor: const Color(0xFF1877F2),
                            child: const FaIcon(FontAwesomeIcons.facebookF,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 20),
                          _socialLogo(
                            onTap: () => _socialSnack('Instagram'),
                            bgColor: Colors.transparent,
                            isGradient: true,
                            child: const FaIcon(FontAwesomeIcons.instagram,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isFr
                                ? "Pas encore de compte? "
                                : "Don't have an account? ",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text(
                              isFr ? 'S\'inscrire' : 'Create one',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tip box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                  alpha: 0.12)),
                        ),
                        child: Text(
                          isFr
                              ? '🔑 Astuce: "tenant1@spacerentals.cm" / "Password123!"'
                              : '🔑 Tip: "tenant1@spacerentals.cm" / "Password123!"',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Admin Login link
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showAdminLoginModal(context, isFr),
                          icon: const Icon(Icons.admin_panel_settings, size: 16),
                          label: Text(
                            isFr ? 'Je suis un administrateur' : 'I am an Administrator',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminLoginModal(BuildContext context, bool isFr) {
    final adminEmailController = TextEditingController(text: 'admin@spacerentals.cm');
    final adminPasswordController = TextEditingController(text: 'Password123!');
    bool isLoading = false;
    final router = GoRouter.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            isFr ? 'Accès Administrateur' : 'Admin Access',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFr 
                        ? 'Connectez-vous pour accéder au tableau de bord administrateur.' 
                        : 'Sign in to access the admin dashboard.',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _inputField(
                    controller: adminEmailController,
                    label: isFr ? 'Email Admin' : 'Admin Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    controller: adminPasswordController,
                    label: isFr ? 'Mot de passe' : 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      setState(() => isLoading = true);
                      try {
                        final success = await ref.read(authProvider.notifier).signIn(
                          adminEmailController.text,
                          adminPasswordController.text,
                        );
                        if (!ctx.mounted) return;
                        if (success) {
                          Navigator.pop(ctx);
                          router.go('/admin');
                        } else {
                          setState(() => isLoading = false);
                          final error = ref.read(authProvider).error ?? 'Login failed';
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isFr ? 'Connexion Admin' : 'Admin Login', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _socialSnack(String provider) {
    Fluttertoast.showToast(
      msg: '$provider login requires OAuth setup in your Supabase dashboard.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Widget _socialLogo({
    required VoidCallback onTap,
    required Widget child,
    required Color bgColor,
    Color? borderColor,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isGradient ? null : bgColor,
          gradient: isGradient
              ? const LinearGradient(
                  colors: [
                    Color(0xFFF58529),
                    Color(0xFFDD2A7B),
                    Color(0xFF8134AF),
                    Color(0xFF515BD4),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
      ),
    );
  }
}
