import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../widgets/animated_loading_button.dart';

class AgentKYCScreen extends ConsumerStatefulWidget {
  const AgentKYCScreen({super.key});

  @override
  ConsumerState<AgentKYCScreen> createState() => _AgentKYCScreenState();
}

class _AgentKYCScreenState extends ConsumerState<AgentKYCScreen> {
  bool _isLoading = false;

  final Map<String, String?> _uploadedDocs = {
    'id_card': null,
    'agency_license': null,
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
    return _uploadedDocs['id_card'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.go('/home'); // Send them back home if they cancel
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
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'As an Agent, you must verify your identity before you can add properties and earn commissions.',
                      style: TextStyle(fontSize: 13, color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Required Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            _uploadTile(
              title: 'National ID Card (CNI)',
              docKey: 'id_card',
              isOptional: false,
            ),
            _uploadTile(
              title: 'Agency License',
              docKey: 'agency_license',
              isOptional: true,
            ),
            _uploadTile(
              title: 'Taxpayer Card',
              docKey: 'tax_card',
              isOptional: true,
            ),

            const SizedBox(height: 40),
            AnimatedLoadingButton(
              onPressed: _canSubmit() ? () async {
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 1));
                
                final user = ref.read(authProvider);
                if (user != null) {
                  Map<String, String> docs = {};
                  docs['ID Card'] = _uploadedDocs['id_card']!;
                  if (_uploadedDocs['agency_license'] != null) {
                    docs['Agency License'] = _uploadedDocs['agency_license']!;
                  }
                  if (_uploadedDocs['tax_card'] != null) {
                    docs['Taxpayer Card'] = _uploadedDocs['tax_card']!;
                  }
                  
                  final submission = KYCSubmission(
                    userId: user.session?.userId ?? 'unknown',
                    userName: user.session?.fullName ?? 'Unknown',
                    userEmail: user.session?.email ?? '',
                    isPremium: false,
                    status: 'pending',
                    submittedAt: DateTime.now(),
                    documents: docs,
                  );
                  
                  // TODO: Connect this to api_agent_repository method: submitKyc()
                  // ref.read(kycSubmissionsProvider.notifier).submit(submission);
                }
                
                // TODO: When backend is connected, call API to update KYC status.
                // For now, navigate to the pending screen directly.
                if (mounted) context.go('/agent/pending');
              } : () async {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _canSubmit() ? theme.colorScheme.primary : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Submit for Verification',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
