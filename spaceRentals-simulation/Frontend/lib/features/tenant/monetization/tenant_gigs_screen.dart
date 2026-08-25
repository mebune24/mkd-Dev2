import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/ui_helpers.dart';

class TenantGigsScreen extends StatefulWidget {
  const TenantGigsScreen({super.key});

  @override
  State<TenantGigsScreen> createState() => _TenantGigsScreenState();
}

class _TenantGigsScreenState extends State<TenantGigsScreen> {
  final List<Map<String, dynamic>> _gigs = [
    {
      'id': 'g1',
      'title': 'Tonte de gazon - Cour avant',
      'payout': 10000.0,
      'distance': 'À 200m (Votre immeuble)',
      'description': 'L\'herbe de la cour avant a besoin d\'être tondue. Matériel disponible dans le local technique.',
      'status': 'open',
    },
    {
      'id': 'g2',
      'title': 'Nettoyage des couloirs',
      'payout': 15000.0,
      'distance': 'À 50m (Bâtiment B)',
      'description': 'Balayage et nettoyage à la serpillière des couloirs des 3 étages.',
      'status': 'open',
    },
    {
      'id': 'g3',
      'title': 'Remplacement ampoules parking',
      'payout': 5000.0,
      'distance': 'À 200m (Votre immeuble)',
      'description': 'Remplacer 4 ampoules défectueuses dans le parking sous-terrain.',
      'status': 'open',
    }
  ];

  void _showSubmissionOverlay(BuildContext context, Map<String, dynamic> gig) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSubmissionOverlay(gig: gig),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Micro-Tâches Communautaires'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _gigs.length,
        itemBuilder: (context, index) {
          final gig = _gigs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        CurrencyFormatter.formatCFA(gig['payout'] as double),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(gig['distance'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(gig['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(gig['description'], style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSubmissionOverlay(context, gig),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Accepter la tâche', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhotoSubmissionOverlay extends StatefulWidget {
  final Map<String, dynamic> gig;
  const _PhotoSubmissionOverlay({required this.gig});

  @override
  State<_PhotoSubmissionOverlay> createState() => _PhotoSubmissionOverlayState();
}

class _PhotoSubmissionOverlayState extends State<_PhotoSubmissionOverlay> {
  File? _beforeImage;
  File? _afterImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isBefore) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(image.path);
        } else {
          _afterImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Soumission : ${widget.gig['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Veuillez fournir des photos avant et après pour valider la tâche et recevoir votre paiement.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildPhotoTarget('Avant', _beforeImage, () => _pickImage(true), theme)),
                const SizedBox(width: 16),
                Expanded(child: _buildPhotoTarget('Après', _afterImage, () => _pickImage(false), theme)),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (_beforeImage != null && _afterImage != null)
                  ? () {
                      Navigator.pop(context);
                      context.showToast('Tâche soumise pour validation !');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Soumettre pour paiement', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTarget(String label, File? image, VoidCallback onTap, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: image != null
                  ? Image.file(image, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey.shade400, size: 32),
                        const SizedBox(height: 8),
                        Text('Prendre photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
