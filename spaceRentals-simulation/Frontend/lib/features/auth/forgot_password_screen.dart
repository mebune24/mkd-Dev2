import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/animated_loading_button.dart';
import '../../core/utils/ui_helpers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;
    await Future.delayed(const Duration(milliseconds: 1500)); 
    if (!mounted) return;
    setState(() => _emailSent = true);
    Fluttertoast.showToast(
      msg: 'Reset link sent to ${_emailController.text.trim()}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isFr = locale.languageCode == 'fr';
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Gradient Header ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: size.height * 0.32,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(top: -40, right: -20,
                      child: Container(width: 140, height: 140,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)))),
                    Positioned(bottom: -10, left: -30,
                      child: Container(width: 110, height: 110,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)))),
                    // Back button
                    Positioned(
                      top: 50,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    // Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: _emailSent
                                  ? const Icon(Icons.mark_email_read_rounded, size: 48, color: Colors.white)
                                  : const Icon(Icons.lock_reset_rounded, size: 48, color: Colors.white),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isFr ? 'Mot de passe oublié' : 'Forgot Password',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _emailSent
                                  ? (isFr ? 'Vérifiez votre boîte mail' : 'Check your inbox')
                                  : (isFr ? 'Saisissez votre adresse e-mail' : 'Enter your email address'),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: _emailSent ? _buildSuccessView(context, isFr, theme) : _buildFormView(isFr, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isFr, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isFr ? 'Réinitialiser le mot de passe' : 'Reset your password',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            isFr
                ? 'Nous vous enverrons un lien de réinitialisation par e-mail.'
                : 'We\'ll send a password reset link to your email.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // Email field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isFr ? 'L\'email est requis' : 'Email is required';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return isFr ? 'Email invalide' : 'Invalid email format';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: isFr ? 'Adresse e-mail' : 'Email address',
                labelStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          AnimatedLoadingButton(
            onPressed: _handleSendReset,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  isFr ? 'Envoyer le lien' : 'Send Reset Link',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFr ? 'Vous vous souvenez de votre mot de passe? ' : 'Remember your password? ',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  isFr ? 'Se connecter' : 'Sign In',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isFr
                        ? 'Le lien de réinitialisation expirera dans 30 minutes. Vérifiez également vos spams.'
                        : 'The reset link will expire in 30 minutes. Also check your spam folder.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, bool isFr, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Success icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isFr ? 'E-mail envoyé !' : 'Email sent!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          isFr
              ? 'Nous avons envoyé un lien de réinitialisation à ${_emailController.text.trim()}. Vérifiez votre boîte mail.'
              : 'We\'ve sent a reset link to ${_emailController.text.trim()}. Check your inbox.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            isFr ? 'Retour à la connexion' : 'Back to Sign In',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() => _emailSent = false),
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(isFr ? 'Renvoyer le lien' : 'Resend link'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
