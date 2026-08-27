import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/enums.dart';
import '../../features/auth/domain/user_session.dart';
import '../../widgets/animated_loading_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/utils/ui_helpers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralController = TextEditingController();
  String _selectedRole = 'tenant';
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralController.dispose();
    super.dispose();
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
            // ── Compact gradient header ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: size.height * 0.25,
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
                    top: -40,
                    left: -20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -10,
                    child: Container(
                      width: 100,
                      height: 100,
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
                  // Back button
                  Positioned(
                    top: 50,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.apartment_rounded, size: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isFr ? 'Créer un compte' : 'Create Account',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isFr
                              ? 'Rejoignez des milliers de locataires'
                              : 'Join thousands of happy renters',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full name
                      _inputField(
                        controller: _nameController,
                        label: isFr ? 'Nom complet' : 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isFr ? 'Le nom est requis' : 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      _inputField(
                        controller: _emailController,
                        label: isFr ? 'Adresse e-mail' : 'Email Address',
                        icon: Icons.email_outlined,
                        type: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isFr ? 'L\'email est requis' : 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return isFr ? 'Email invalide' : 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _inputField(
                        controller: _passwordController,
                        label: isFr ? 'Mot de passe' : 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: _obscurePass,
                        onToggleObscure: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isFr ? 'Le mot de passe est requis' : 'Password is required';
                          }
                          if (value.length < 8) {
                            return isFr ? 'Au moins 8 caractères' : 'Must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return isFr ? 'Doit contenir une majuscule' : 'Must contain an uppercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return isFr ? 'Doit contenir un chiffre' : 'Must contain a number';
                          }
                          if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                            return isFr ? 'Doit contenir un caractère spécial (!@#\$&*~)' : 'Must contain a special character (!@#\$&*~)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm password
                      _inputField(
                        controller: _confirmController,
                        label: isFr
                            ? 'Confirmer le mot de passe'
                            : 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: _obscureConfirm,
                        onToggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return isFr ? 'Les mots de passe ne correspondent pas' : 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Optional Referral Code
                      _inputField(
                        controller: _referralController,
                        label: isFr ? 'Code de parrainage (Optionnel)' : 'Referral Code (Optional)',
                        icon: Icons.card_giftcard,
                      ),
                      const SizedBox(height: 14),

                      // Role selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: isFr ? 'Je suis...' : 'I am a...',
                            labelStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: Colors.grey, size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'tenant',
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      size: 18,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Text(isFr
                                      ? 'Locataire'
                                      : 'Tenant'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'landlord',
                              child: Row(
                                children: [
                                  Icon(Icons.business,
                                      size: 18,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Text(isFr
                                      ? 'Propriétaire'
                                      : 'Landlord'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'agent',
                              child: Row(
                                children: [
                                  Icon(Icons.handshake,
                                      size: 18,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Text(isFr
                                      ? 'Agent Immobilier'
                                      : 'Agent'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedRole = val);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms checkbox
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _agreedToTerms
                                    ? theme.colorScheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreedToTerms
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: isFr
                                      ? 'J\'accepte les '
                                      : 'I agree to the ',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  children: [
                                    TextSpan(
                                      text: isFr
                                          ? 'conditions d\'utilisation'
                                          : 'Terms of Service',
                                      style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: isFr ? ' et la ' : ' and ',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    TextSpan(
                                      text: isFr
                                          ? 'politique de confidentialité'
                                          : 'Privacy Policy',
                                      style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register button
                      AnimatedLoadingButton(
                        onPressed: _agreedToTerms
                            ? () async {
                                if (_nameController.text.trim().isEmpty || 
                                    _emailController.text.trim().isEmpty || 
                                    _passwordController.text.isEmpty || 
                                    _confirmController.text.isEmpty) {
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

                                // Determine role from dropdown
                                Role roleToRegister = Role.tenant;
                                if (_selectedRole == 'landlord') roleToRegister = Role.landlord;
                                if (_selectedRole == 'agent') roleToRegister = Role.agent;

                                try {
                                  final nameParts = _nameController.text.trim().split(' ');
                                  await ref.read(authProvider.notifier).signUp(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    firstName: nameParts.isNotEmpty ? nameParts.first : _nameController.text.trim(),
                                    lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
                                    role: roleToRegister.name,
                                  );

                                  if (!mounted) return;

                                  Fluttertoast.showToast(
                                    msg: isFr ? 'Compte créé avec succès!' : 'Account created successfully!',
                                    backgroundColor: Colors.green,
                                  );

                                  // Read the FRESHLY set state — it's set synchronously after await
                                  final authState = ref.read(authProvider);
                                  if (authState.session == null) {
                                    context.go('/login');
                                    return;
                                  }

                                  if (authState.session!.role == Role.landlord) {
                                    // Landlords always go to KYC first
                                    context.go('/landlord/kyc');
                                  } else if (authState.session!.role == Role.agent) {
                                    // Agents go to the onboarding/KYC flow
                                    context.go('/agent/onboarding');
                                  } else if (authState.session!.role == Role.admin) {
                                    context.go('/admin');
                                  } else {
                                    // Default: tenant
                                    context.go('/tenant');
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  Fluttertoast.showToast(
                                    msg: e.toString().replaceFirst('Exception: ', ''),
                                    backgroundColor: Colors.red,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                }
                              }
                            : () async {}, // Disabled visually handled by AnimatedLoadingButton? Actually, we'll keep it simple
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          backgroundColor: _agreedToTerms ? theme.colorScheme.primary : Colors.grey,
                        ),
                        child: Text(
                          isFr ? 'Créer mon compte' : 'Create Account',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Social divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              isFr
                                  ? 'ou s\'inscrire avec'
                                  : 'or sign up with',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social logos — horizontal
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
                            isGradient: true,
                            bgColor: Colors.transparent,
                            child: const FaIcon(FontAwesomeIcons.instagram,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isFr
                                ? 'Vous avez déjà un compte? '
                                : 'Already have an account? ',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              isFr ? 'Se connecter' : 'Sign In',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType type = TextInputType.text,
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
              offset: const Offset(0, 3))
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && obscure,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
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
      ),
    );
  }
}
