import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/di_providers.dart';
import '../../core/utils/ui_helpers.dart';
import '../../services/socket_service.dart';

class LandlordPendingScreen extends ConsumerStatefulWidget {
  const LandlordPendingScreen({super.key});

  @override
  ConsumerState<LandlordPendingScreen> createState() =>
      _LandlordPendingScreenState();
}

class _LandlordPendingScreenState extends ConsumerState<LandlordPendingScreen> {
  bool _checking = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkStatus(silent: true),
    );
    final token = ref.read(authProvider).session?.accessToken;
    if (token != null) {
      final socket = ref.read(socketServiceProvider);
      socket.connect(token);
      socket.onNotification((notification) {
        if (notification['type'] == 'landlord_kyc_approved' ||
            notification['type'] == 'landlord_kyc_rejected') {
          _checkStatus(silent: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    ref.read(socketServiceProvider).offNotification();
    super.dispose();
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final session = await ref.read(authRepositoryProvider).refreshSession();
      if (!mounted) return;
      if (session.isKycVerified) {
        await ref.read(authProvider.notifier).updateSessionKycStatus(
          isVerified: true,
          kycStatus: session.kycStatus,
        );
        context.go('/landlord');
        return;
      }
      if (session.kycStatus == 'rejected' ||
          session.kycStatus == 'not_submitted') {
        await ref.read(authProvider.notifier).updateSessionKycStatus(
          isVerified: false,
          kycStatus: session.kycStatus,
        );
        if (mounted) context.go('/landlord/kyc');
        return;
      }
      if (!silent) {
        final isFr = ref.read(localeProvider).languageCode == 'fr';
        context.showToast(
          isFr
              ? 'Toujours en attente de vérification par l\'administrateur.'
              : 'Still pending admin verification.',
        );
      }
    } catch (error) {
      if (mounted && !silent) context.showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFr = ref.watch(localeProvider).languageCode == 'fr';
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isFr
              ? 'Étape 2: Vérification en Cours'
              : 'Step 2: Verification Pending',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back to KYC screen
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top,
                  size: 64,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isFr ? 'Compte en cours d\'examen' : 'Account Under Review',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isFr
                    ? 'Merci ${user.session?.fullName ?? ''} ! Vos documents KYC ont été soumis avec succès.\n\nNotre équipe d\'administration examine vos informations. Ce processus prend généralement de 24 à 48 heures.'
                    : 'Thank you ${user.session?.fullName ?? ''}! Your KYC documents have been successfully submitted.\n\nOur admin team is reviewing your information. This process usually takes 24 to 48 hours.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Refresh button to simulate checking status again
              OutlinedButton.icon(
                onPressed: _checking ? null : _checkStatus,
                icon: const Icon(Icons.refresh),
                label: Text(isFr ? 'Vérifier le statut' : 'Check Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
