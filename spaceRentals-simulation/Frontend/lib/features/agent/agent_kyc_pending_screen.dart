import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/domain_providers.dart';
import '../../providers/di_providers.dart';

class AgentKycPendingScreen extends ConsumerStatefulWidget {
  const AgentKycPendingScreen({super.key});

  @override
  ConsumerState<AgentKycPendingScreen> createState() => _AgentKycPendingScreenState();
}

class _AgentKycPendingScreenState extends ConsumerState<AgentKycPendingScreen>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Poll every 30 seconds for KYC status update
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkKycStatus());
    // Also check immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkKycStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkKycStatus() async {
    if (_isPolling || !mounted) return;
    setState(() => _isPolling = true);
    try {
      // Refresh session from backend to pick up any KYC status changes
      final repo = ref.read(authRepositoryProvider);
      final refreshed = await repo.refreshSession();
      if (!mounted) return;
      if (refreshed.isKycVerified) {
        // Admin has approved! Update state and navigate.
        ref.read(authProvider.notifier).updateSessionKycStatus(isVerified: true);
        _showApprovalCelebration();
      }
    } catch (_) {
      // Silently fail — we'll try again next cycle
    } finally {
      if (mounted) setState(() => _isPolling = false);
    }
  }

  void _showApprovalCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, size: 72, color: Colors.green),
              ),
              const SizedBox(height: 24),
              const Text(
                '🎉 You\'re Approved!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Agent account is now active. You can start listing properties and earning commissions!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/agent/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Go to My Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final session = authState.session;

    // If KYC was approved while on this screen, redirect
    if (session?.isKycVerified == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/agent/dashboard');
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Verification Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status Card ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50.withValues(
                              alpha: 0.5 + 0.5 * _pulseController.value,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: child,
                        );
                      },
                      child: const Icon(Icons.hourglass_top_rounded,
                          size: 60, color: Colors.orange),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Profile Under Review',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      session != null
                          ? 'Hi ${session.firstName}, our team is reviewing your submitted documents. This usually takes 24–48 hours.'
                          : 'Our team is reviewing your submitted documents. This usually takes 24–48 hours.',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Progress indicator
                    Row(
                      children: [
                        _StepDot(label: 'Submitted', isComplete: true, color: Colors.green),
                        Expanded(child: Container(height: 2, color: Colors.orange.shade200)),
                        _StepDot(label: 'In Review', isComplete: false, color: Colors.orange, isActive: true),
                        Expanded(child: Container(height: 2, color: Colors.grey.shade200)),
                        _StepDot(label: 'Approved', isComplete: false, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Info Banner ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'While you wait, feel free to browse properties and explore the platform.',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Browse Breadcrumb ──────────────────────────────────────
              _ActionTile(
                icon: Icons.explore_rounded,
                title: 'Browse Properties',
                subtitle: 'Search and explore available listings',
                color: Colors.blue,
                onTap: () => context.go('/tenant'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Talk to AI Assistant',
                subtitle: 'Ask the chatbot about the platform',
                color: Colors.purple,
                onTap: () => context.go('/chatbot'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.notifications_outlined,
                title: 'Check Notifications',
                subtitle: 'You\'ll be notified when approved',
                color: Colors.teal,
                onTap: () => context.go('/notifications'),
              ),
              const SizedBox(height: 28),

              // ── Manual refresh button ──────────────────────────────────
              OutlinedButton.icon(
                onPressed: _isPolling ? null : _checkKycStatus,
                icon: _isPolling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(_isPolling ? 'Checking...' : 'Refresh Status'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isComplete;
  final bool isActive;
  final Color color;

  const _StepDot({
    required this.label,
    required this.isComplete,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isComplete || isActive ? color : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: isComplete
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : isActive
                  ? Icon(Icons.circle, color: color, size: 10)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isComplete || isActive ? color : Colors.grey,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
