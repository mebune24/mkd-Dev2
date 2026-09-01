import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/property_provider.dart';
import '../../providers/di_providers.dart';
import '../../providers/auth_provider.dart';
import '../../features/properties/domain/property.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/ui_helpers.dart';
import '../../widgets/form_safe_modal.dart';
import '../../core/api/storage_service.dart';

class AddProperty extends ConsumerStatefulWidget {
  const AddProperty({super.key});

  @override
  ConsumerState<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends ConsumerState<AddProperty> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Basic Info
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  String _category = 'Apartments';
  int _bedrooms = 1;
  int _bathrooms = 1;
  final _areaCtrl = TextEditingController();
  int _parkingSpaces = 0;
  int _floor = 0;
  int _totalFloors = 1;
  final _yearBuiltCtrl = TextEditingController();
  bool _furnished = false;

  // Amenities
  bool _hasWater = false;
  bool _hasElectricity = false;
  bool _isFenced = false;
  bool _closeToRoad = false;
  String _securityMeans = 'None';
  final Set<String> _nearbyAmenities = {};

  // Media
  final List<XFile> _photos = [];
  final List<XFile> _floorPlanImages = [];
  final List<XFile> _videoFiles = [];
  final ImagePicker _picker = ImagePicker();

  // Terms
  final List<String> _terms = [
    'No pets allowed without prior written consent.',
    'Minimum lease duration of 12 months.',
    'Tenant is responsible for minor repairs.',
    'No subletting without landlord approval.',
    'One month notice required for early termination.',
  ];

  static const List<String> _categories = ['Apartments', 'Studios', 'Villas', 'Commercial', 'Luxury', 'Student Housing', 'Shared', 'Short Stays'];
  static const List<String> _securityOptions = ['None', 'Security Guard', 'CCTV', 'Gated Community', 'Dog', 'Electric Fence'];
  static const List<String> _amenitiesList = ['School Nearby', 'Hospital Nearby', 'Market Nearby', 'Bus Stop', 'Supermarket', 'Pharmacy', 'Bank / ATM', 'Church / Mosque'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _areaCtrl.dispose();
    _yearBuiltCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormSafeModal(
      hasUnsavedChanges: _titleCtrl.text.isNotEmpty || _descCtrl.text.isNotEmpty || _rentCtrl.text.isNotEmpty,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          title: const Text('List a Property'),
          flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (i) => setState(() => _currentStep = i),
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              _publishProperty();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_currentStep == 4 ? 'Publish Property 🚀' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Basic Info'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildBasicInfoStep(theme),
            ),
            Step(
              title: const Text('Details & Specs'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildDetailsStep(theme),
            ),
            Step(
              title: const Text('Amenities'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildAmenitiesStep(theme),
            ),
            Step(
              title: const Text('Photos & Media'),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: _buildMediaStep(theme),
            ),
            Step(
              title: const Text('Review & Publish'),
              isActive: _currentStep >= 4,
              state: StepState.indexed,
              content: _buildReviewStep(theme),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBasicInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Property Title', _titleCtrl, required: true, hint: 'e.g. Spacious 3-Bedroom Villa'),
        const SizedBox(height: 14),
        _field('Location / Address', _locationCtrl, required: true, hint: 'e.g. Bastos, Yaoundé'),
        const SizedBox(height: 14),
        _field('Description', _descCtrl, maxLines: 4, hint: 'Describe your property in detail...'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Monthly Rent (FCFA)', _rentCtrl, required: true, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _field('Deposit (FCFA)', _depositCtrl, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 14),
        _label('Category'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: _inputDecor('Category'),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _counterField('Bedrooms', _bedrooms, (v) => setState(() => _bedrooms = v), min: 0, max: 20)),
            const SizedBox(width: 12),
            Expanded(child: _counterField('Bathrooms', _bathrooms, (v) => setState(() => _bathrooms = v), min: 1, max: 20)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Area (m²)', _areaCtrl, keyboardType: TextInputType.number, hint: '0')),
            const SizedBox(width: 12),
            Expanded(child: _counterField('Parking', _parkingSpaces, (v) => setState(() => _parkingSpaces = v), min: 0, max: 20)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _counterField('Floor', _floor, (v) => setState(() => _floor = v), min: 0, max: 100)),
            const SizedBox(width: 12),
            Expanded(child: _counterField('Total Floors', _totalFloors, (v) => setState(() => _totalFloors = v), min: 1, max: 100)),
          ],
        ),
        const SizedBox(height: 14),
        _field('Year Built', _yearBuiltCtrl, keyboardType: TextInputType.number, hint: 'e.g. 2020'),
        const SizedBox(height: 14),
        SwitchListTile(
          title: const Text('Furnished', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Property includes furniture'),
          value: _furnished,
          activeColor: theme.colorScheme.primary,
          onChanged: (v) => setState(() => _furnished = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAmenitiesStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Utilities & Features'),
        const SizedBox(height: 10),
        _switchTile('Running Water', _hasWater, (v) => setState(() => _hasWater = v), Icons.water_drop, Colors.blue, theme),
        _switchTile('Electricity (AES/ENEO)', _hasElectricity, (v) => setState(() => _hasElectricity = v), Icons.bolt, Colors.amber, theme),
        _switchTile('Fenced Compound', _isFenced, (v) => setState(() => _isFenced = v), Icons.fence, Colors.brown, theme),
        _switchTile('Close to Main Road', _closeToRoad, (v) => setState(() => _closeToRoad = v), Icons.traffic, Colors.orange, theme),
        const SizedBox(height: 16),
        _label('Security'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _securityMeans,
          decoration: _inputDecor('Security Type'),
          items: _securityOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _securityMeans = v!),
        ),
        const SizedBox(height: 16),
        _label('Nearby Amenities'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenitiesList.map((amenity) {
            final selected = _nearbyAmenities.contains(amenity);
            return GestureDetector(
              onTap: () => setState(() => selected ? _nearbyAmenities.remove(amenity) : _nearbyAmenities.add(amenity)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? theme.colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? theme.colorScheme.primary : Colors.grey.shade300),
                ),
                child: Text(amenity, style: TextStyle(color: selected ? Colors.white : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMediaStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Property Photos *'),
        const SizedBox(height: 8),
        _mediaPickerSection(
          items: _photos,
          icon: Icons.add_a_photo,
          label: 'Add Photos',
          color: theme.colorScheme.primary,
          onPick: () async {
            final picked = await _picker.pickMultiImage(imageQuality: 80);
            setState(() => _photos.addAll(picked));
          },
          onRemove: (i) => setState(() => _photos.removeAt(i)),
          isImage: true,
        ),
        const SizedBox(height: 20),
        _label('Floor Plan Images'),
        const SizedBox(height: 8),
        _mediaPickerSection(
          items: _floorPlanImages,
          icon: Icons.architecture,
          label: 'Upload Floor Plans',
          color: Colors.indigo,
          onPick: () async {
            final picked = await _picker.pickMultiImage();
            setState(() => _floorPlanImages.addAll(picked));
          },
          onRemove: (i) => setState(() => _floorPlanImages.removeAt(i)),
          isImage: true,
        ),
        const SizedBox(height: 20),
        _label('Video Tour'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
            if (video != null) setState(() => _videoFiles.add(video));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.4), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.videocam, size: 36, color: Colors.red.withValues(alpha: 0.7)),
                const SizedBox(height: 8),
                Text(_videoFiles.isEmpty ? 'Tap to Upload Video Tour' : '${_videoFiles.length} video(s) selected ✓', style: TextStyle(color: _videoFiles.isEmpty ? Colors.grey : Colors.green, fontWeight: FontWeight.w600)),
                const Text('Max 5 minutes', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reviewRow('Title', _titleCtrl.text.isEmpty ? 'Not set' : _titleCtrl.text),
        _reviewRow('Location', _locationCtrl.text.isEmpty ? 'Not set' : _locationCtrl.text),
        _reviewRow('Monthly Rent', _rentCtrl.text.isEmpty ? 'Not set' : '${CurrencyFormatter.formatCFA(double.tryParse(_rentCtrl.text) ?? 0)} / mo'),
        _reviewRow('Category', _category),
        _reviewRow('Bedrooms / Baths', '$_bedrooms bed / $_bathrooms bath'),
        _reviewRow('Area', '${_areaCtrl.text.isEmpty ? '—' : _areaCtrl.text} m²'),
        _reviewRow('Furnished', _furnished ? 'Yes' : 'No'),
        _reviewRow('Photos', '${_photos.length} uploaded'),
        _reviewRow('Floor Plans', '${_floorPlanImages.length} uploaded'),
        _reviewRow('Videos', '${_videoFiles.length} uploaded'),
        const SizedBox(height: 16),
        _label('Rental Terms'),
        const SizedBox(height: 8),
        ..._terms.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.black87))),
            ],
          ),
        )),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _field(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecor(label).copyWith(hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label is required' : null : null,
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));

  Widget _counterField(String label, int value, ValueChanged<int> onChanged, {required int min, required int max}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(onTap: () { if (value > min) onChanged(value - 1); }, child: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              GestureDetector(onTap: () { if (value < max) onChanged(value + 1); }, child: Icon(Icons.add_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged, IconData icon, Color color, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? color.withValues(alpha: 0.3) : Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Row(children: [Icon(icon, size: 18, color: value ? color : Colors.grey), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))]),
        value: value,
        activeColor: color,
        onChanged: onChanged,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _mediaPickerSection({
    required List<XFile> items,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPick,
    required ValueChanged<int> onRemove,
    required bool isImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isImage
                          ? Image.file(File(items[index].path), width: 100, height: 100, fit: BoxFit.cover)
                          : Container(width: 100, height: 100, color: Colors.black12, child: const Icon(Icons.videocam, size: 40, color: Colors.grey)),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                if (items.isNotEmpty) Text(' (${items.length})', style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  void _publishProperty() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    setState(() => _isLoading = true);
    
    if (!mounted) return;

    final user = ref.read(authProvider);
    final repo = ref.read(propertyRepositoryProvider);

    try {
      List<String> imageUrls = [];
      if (_photos.isNotEmpty) {
        imageUrls = await StorageService.instance.uploadMultipleFiles(_photos, 'property-images');
      } else {
        imageUrls = ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'];
      }

      List<String> floorPlans = [];
      if (_floorPlanImages.isNotEmpty) {
        floorPlans = await StorageService.instance.uploadMultipleFiles(_floorPlanImages, 'property-images');
      }

      List<String> videoUrls = [];
      if (_videoFiles.isNotEmpty) {
        videoUrls = await StorageService.instance.uploadMultipleFiles(_videoFiles, 'property-images');
      }

      await repo.submitProperty(
        title: _titleCtrl.text,
        description: _descCtrl.text.isEmpty ? 'No description provided.' : _descCtrl.text,
        location: _locationCtrl.text,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        monthlyRentUnits: (double.tryParse(_rentCtrl.text) ?? 0).toInt(),
        depositUnits: (double.tryParse(_depositCtrl.text) ?? 0).toInt(),
        imageUrls: imageUrls,
        category: _category,
        amenities: {
          'hasWater': _hasWater,
          'hasElectricity': _hasElectricity,
          'isFenced': _isFenced,
          'closeToRoad': _closeToRoad,
          'securityMeans': _securityMeans,
          'furnished': _furnished,
          'parkingSpaces': _parkingSpaces,
          'floor': _floor,
          'totalFloors': _totalFloors,
          'nearbyAmenities': _nearbyAmenities.toList(),
          'floorPlanImages': floorPlans,
          'videoUrls': videoUrls,
          'rentalAgreementTerms': _terms,
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to publish property: $e')));
      }
      return;
    }

    // Refresh providers
    ref.invalidate(landlordPropertiesProvider);
    ref.invalidate(marketplaceListingsProvider);

    setState(() => _isLoading = false);

    if (!mounted) return;
    context.showAppDialog(builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 52)),
            const SizedBox(height: 16),
            const Text('Property Listed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Your property is now live on SpaceRentals. Tenants can start browsing and applying.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { Navigator.pop(ctx); context.go('/landlord'); },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}
