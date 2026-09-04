import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../shared/models/enums.dart';
import '../../features/auth/domain/user_session.dart';
import '../../providers/domain_providers.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (authState.session!.role == Role.admin) {
          context.go('/admin');
        } else if (authState.session!.role == Role.landlord) {
          final kycList = await ref.read(kycSubmissionsProvider.future);
          final userKyc = kycList.where((k) => k.userId == authState.session!.userId);
          final isKycVerified = userKyc.isNotEmpty && (userKyc.first.status == 'verified' || userKyc.first.status == 'premium');
          final isKycPending = userKyc.isNotEmpty && userKyc.first.status == 'pending';
          
          if (isKycPending) {
            context.go('/landlord/pending');
          } else if (!isKycVerified && userKyc.isEmpty) {
            context.go('/landlord/kyc');
          } else {
            context.go('/landlord');
          }
        } else if (authState.session!.role == Role.agent) {
          context.go('/agent/dashboard');
        } else {
          context.go('/tenant');
        }
      } else {
        // First-time users see onboarding before login
        final seenOnboarding = await hasSeenOnboarding();
        if (!mounted) return;
        if (seenOnboarding) {
          context.go('/login');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D0057), Color(0xFF5D3F6A), Color(0xFF1A0033)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow effect
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B2FBE).withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.apartment_rounded,
                            size: 80,
                            color: Color(0xFF7B2FBE),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App Name
                  const Text(
                    'SpaceRentals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  const Text(
                    'Your perfect space awaits',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
