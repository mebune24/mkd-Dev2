import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';
import '../../providers/di_providers.dart';
import '../../features/properties/domain/property.dart';
import '../../core/utils/ui_helpers.dart';

class MyProperties extends ConsumerWidget {
  const MyProperties({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(landlordPropertiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Properties')),
      body: propertiesAsync.when(
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(child: Text('You have no properties listed yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                item: property,
                onTap: () {
                  // View property details for landlord
                },
                bottomActions: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          context.showToast('Edit feature coming soon.');
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Property'),
                              content: Text('Are you sure you want to delete "${property.property.title}"? This cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await ref.read(propertyRepositoryProvider).unpublishListing(property.property.id);
                                    ref.invalidate(landlordPropertiesProvider);
                                    if (context.mounted) {
                                      context.showToast('"${property.property.title}" deleted.');
                                    }
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Failed to load properties', style: TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => ref.invalidate(landlordPropertiesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
