import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/properties/domain/property.dart';
import '../../providers/di_providers.dart';
import '../../providers/property_provider.dart';
import '../../providers/domain_providers.dart';
import '../../core/utils/ui_helpers.dart';

class EditProperty extends ConsumerStatefulWidget {
  final PropertyWithListing property;

  const EditProperty({required this.property, super.key});

  @override
  ConsumerState<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends ConsumerState<EditProperty> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _rentController;
  late final TextEditingController _depositController;
  late String _category;
  late int _bedrooms;
  late int _bathrooms;
  late bool _furnished;
  late final TextEditingController _areaController;
  late int _parkingSpaces;
  late bool _hasWater;
  late bool _hasElectricity;
  late bool _isFenced;
  late bool _closeToRoad;
  late String _securityMeans;
  final Set<String> _amenities = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final property = widget.property.property;
    _titleController = TextEditingController(text: property.title);
    _descriptionController = TextEditingController(text: property.description);
    _locationController = TextEditingController(text: property.location);
    _rentController = TextEditingController(
      text: '${property.monthlyRentUnits}',
    );
    _depositController = TextEditingController(
      text: '${property.depositUnits}',
    );
    _category = property.category;
    _bedrooms = property.bedrooms;
    _bathrooms = property.bathrooms;
    _furnished = property.furnished;
    _areaController = TextEditingController(text: '${property.areaSqM}');
    _parkingSpaces = property.parkingSpaces;
    _hasWater = property.hasWater;
    _hasElectricity = property.hasElectricity;
    _isFenced = property.isFenced;
    _closeToRoad = property.closeToRoad;
    _securityMeans = property.securityMeans;
    _amenities.addAll(property.amenities);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(propertyRepositoryProvider)
          .updateProperty(
            propertyId: widget.property.property.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            monthlyRentUnits: int.parse(_rentController.text.trim()),
            depositUnits: int.parse(_depositController.text.trim()),
            category: _category,
            furnished: _furnished,
            areaSqM: double.parse(_areaController.text.trim()),
            parkingSpaces: _parkingSpaces,
            hasWater: _hasWater,
            hasElectricity: _hasElectricity,
            isFenced: _isFenced,
            closeToRoad: _closeToRoad,
            securityMeans: _securityMeans,
            amenities: _amenities.toList(),
          );
      ref.invalidate(landlordPropertiesProvider);
      ref.invalidate(landlordDashboardProvider);
      if (!mounted) return;
      context.showSuccessToast('Property updated successfully.');
      context.pop();
    } catch (error) {
      if (mounted) context.showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Property title'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monthly rent',
                    ),
                    validator: _positiveInteger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _depositController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Deposit'),
                    validator: _nonNegativeInteger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  const [
                        'Apartments',
                        'Studios',
                        'Villas',
                        'Commercial',
                        'Luxury',
                        'Student Housing',
                        'Shared',
                        'Short Stays',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _bedrooms,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                    items: List.generate(
                      21,
                      (value) =>
                          DropdownMenuItem(value: value, child: Text('$value')),
                    ),
                    onChanged: (value) {
                      if (value != null) setState(() => _bedrooms = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _bathrooms,
                    decoration: const InputDecoration(labelText: 'Bathrooms'),
                    items: List.generate(
                      21,
                      (value) =>
                          DropdownMenuItem(value: value, child: Text('$value')),
                    ),
                    onChanged: (value) {
                      if (value != null) setState(() => _bathrooms = value);
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Furnished'),
              value: _furnished,
              onChanged: (value) => setState(() => _furnished = value),
            ),
            TextFormField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Area (m2)'),
              validator: _nonNegativeDecimal,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _parkingSpaces,
              decoration: const InputDecoration(labelText: 'Parking spaces'),
              items: List.generate(
                21,
                (value) =>
                    DropdownMenuItem(value: value, child: Text('$value')),
              ),
              onChanged: (value) {
                if (value != null) setState(() => _parkingSpaces = value);
              },
            ),
            DropdownButtonFormField<String>(
              value: _securityMeans,
              decoration: const InputDecoration(labelText: 'Security'),
              items:
                  const [
                        'None',
                        'Security Guard',
                        'CCTV',
                        'Gated Community',
                        'Dog',
                        'Electric Fence',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _securityMeans = value);
              },
            ),
            _toggle('Water available', _hasWater, (value) => _hasWater = value),
            _toggle(
              'Electricity available',
              _hasElectricity,
              (value) => _hasElectricity = value,
            ),
            _toggle('Fenced property', _isFenced, (value) => _isFenced = value),
            _toggle(
              'Close to main road',
              _closeToRoad,
              (value) => _closeToRoad = value,
            ),
            const Text(
              'Nearby amenities',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ...[
              'School Nearby',
              'Hospital Nearby',
              'Market Nearby',
              'Bus Stop',
              'Supermarket',
              'Pharmacy',
            ].map(
              (amenity) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(amenity),
                value: _amenities.contains(amenity),
                onChanged: (selected) => setState(() {
                  if (selected == true)
                    _amenities.add(amenity);
                  else
                    _amenities.remove(amenity);
                }),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Changes'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _positiveInteger(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter a positive amount' : null;
  }

  String? _nonNegativeInteger(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Enter a valid amount' : null;
  }

  Widget _toggle(String label, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (next) => setState(() => onChanged(next)),
    );
  }

  String? _nonNegativeDecimal(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Enter a valid area' : null;
  }
}
