import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../widgets/animated_loading_button.dart';

class LandlordKYCScreen extends ConsumerStatefulWidget {
  const LandlordKYCScreen({super.key});

  @override
  ConsumerState<LandlordKYCScreen> createState() => _LandlordKYCScreenState();
}

class _LandlordKYCScreenState extends ConsumerState<LandlordKYCScreen> {
  String _selectedTier = 'basic';
  bool _isLoading = false;

  final Map<String, String?> _uploadedDocs = {
    'id_card': null,
    'land_doc': null,
    'land_title': null,
    'site_plan': null,
    'cni': null,
    'tax_card': null,
  };

  Future<void> _pickImage(String docKey) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      setState(() {
        _uploadedDocs[docKey] = pickedFile.path;
      });
    }
  }

  bool _canSubmit() {
    if (_selectedTier == 'basic') {
      return _uploadedDocs['id_card'] != null && _uploadedDocs['land_doc'] != null;
    } else {
      return _uploadedDocs['land_title'] != null &&
             _uploadedDocs['site_plan'] != null &&
             _uploadedDocs['cni'] != null;
      // Tax card is optional
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFr ? 'Étape 1: Vérification Propriétaire' : 'Step 1: Landlord Verification', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to complete or logout
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isFr 
                          ? 'En tant que propriétaire, vous devez vérifier votre identité et vos propriétés avant de pouvoir utiliser la plateforme.'
                          : 'As a landlord, you must verify your identity and properties before using the platform.',
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(isFr ? 'Niveau de vérification' : 'Verification Tier', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _tierCard(
                    title: isFr ? 'Basique' : 'Basic',
                    value: 'basic',
                    icon: Icons.badge,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tierCard(
                    title: isFr ? 'Premium' : 'Premium',
                    value: 'premium',
                    icon: Icons.star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(isFr ? 'Documents Requis' : 'Required Documents', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            if (_selectedTier == 'basic') ...[
              _uploadTile(
                title: isFr ? 'Carte d\'Identité (CNI)' : 'ID Card (CNI)',
                docKey: 'id_card',
                isOptional: false,
              ),
              _uploadTile(
                title: isFr ? 'Document de Propriété' : 'Land Property Document',
                docKey: 'land_doc',
                isOptional: false,
              ),
            ] else ...[
              _uploadTile(
                title: isFr ? 'Titre Foncier' : 'Land Title (Titre Foncier)',
                docKey: 'land_title',
                isOptional: false,
              ),
              _uploadTile(
                title: isFr ? 'Plan de Situation' : 'Site Plan',
                docKey: 'site_plan',
                isOptional: false,
              ),
              _uploadTile(
                title: isFr ? 'Carte d\'Identité (CNI)' : 'National ID Card (CNI)',
                docKey: 'cni',
                isOptional: false,
              ),
              _uploadTile(
                title: isFr ? 'Carte de Contribuable / Quittance' : 'Taxpayer Card / Tax Receipts',
                docKey: 'tax_card',
                isOptional: true,
              ),
            ],

            const SizedBox(height: 40),
            AnimatedLoadingButton(
              onPressed: _canSubmit() ? () async {
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 1));
                
                final user = ref.read(authProvider);
                if (user != null) {
                  Map<String, String> docs = {};
                  if (_selectedTier == 'basic') {
                    docs['ID Card'] = _uploadedDocs['id_card']!;
                    docs['Land Property Document'] = _uploadedDocs['land_doc']!;
                  } else {
                    docs['Land Title'] = _uploadedDocs['land_title']!;
                    docs['Site Plan'] = _uploadedDocs['site_plan']!;
                    docs['National ID Card (CNI)'] = _uploadedDocs['cni']!;
                    if (_uploadedDocs['tax_card'] != null) {
                      docs['Taxpayer Card'] = _uploadedDocs['tax_card']!;
                    }
                  }
                  
                  final submission = KYCSubmission(
                    userId: user.session?.userId ?? 'unknown',
                    userName: user.session?.fullName ?? 'Unknown',
                    userEmail: user.session?.email ?? '',
                    isPremium: _selectedTier == 'premium',
                    status: 'pending',
                    submittedAt: DateTime.now(),
                    documents: docs,
                  );
                  
                  ref.read(kycSubmissionsProvider.notifier).submit(submission);
                }
                
                if (mounted) context.go('/landlord/pending');
              } : () async {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _canSubmit() ? theme.colorScheme.primary : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isFr ? 'Soumettre pour vérification' : 'Submit for Verification',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tierCard({required String title, required String value, required IconData icon}) {
    final isSelected = _selectedTier == value;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadTile({required String title, required String docKey, required bool isOptional}) {
    final imagePath = _uploadedDocs[docKey];
    final isUploaded = imagePath != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              image: isUploaded
                  ? DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: isUploaded
                ? null
                : const Icon(
                    Icons.upload_file,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (isOptional)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('(Optional)', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      ),
                  ],
                ),
                if (!isUploaded)
                  Text('Tap to upload document', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
                else
                  Text('Uploaded successfully', style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
              ],
            ),
          ),
          if (!isUploaded)
            TextButton(
              onPressed: () => _pickImage(docKey),
              child: const Text('Upload'),
            )
          else
            IconButton(
              onPressed: () => setState(() => _uploadedDocs[docKey] = null),
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }
}
