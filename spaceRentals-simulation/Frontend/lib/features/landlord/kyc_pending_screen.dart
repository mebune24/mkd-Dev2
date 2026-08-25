import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/ui_helpers.dart';
import '../../../core/utils/ui_helpers.dart';

class LandlordPendingScreen extends ConsumerWidget {
  const LandlordPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isFr ? 'Étape 2: Vérification en Cours' : 'Step 2: Verification Pending', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                child: Icon(Icons.hourglass_top, size: 64, color: Colors.orange.shade600),
              ),
              const SizedBox(height: 32),
              Text(
                isFr ? 'Compte en cours d\'examen' : 'Account Under Review',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isFr 
                    ? 'Merci ${user.session?.fullName ?? ''} ! Vos documents KYC ont été soumis avec succès.\n\nNotre équipe d\'administration examine vos informations. Ce processus prend généralement de 24 à 48 heures.'
                    : 'Thank you ${user.session?.fullName ?? ''}! Your KYC documents have been successfully submitted.\n\nOur admin team is reviewing your information. This process usually takes 24 to 48 hours.',
                style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Refresh button to simulate checking status again
              OutlinedButton.icon(
                onPressed: () {
                  context.showToast(isFr ? 'Toujours en attente de vérification par l\'administrateur.' : 'Still pending admin verification.');
                },
                icon: const Icon(Icons.refresh),
                label: Text(isFr ? 'Vérifier le statut' : 'Check Status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
