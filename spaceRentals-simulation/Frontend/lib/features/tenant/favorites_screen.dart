import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/currency_formatter.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFr ? 'Mes Favoris' : 'My Favorites'),
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
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    isFr ? 'Aucun favori pour le moment' : 'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFr ? 'Appuyez sur le cœur pour sauvegarder des propriétés.' : 'Tap the heart icon on properties to save them here.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final property = favorites[index];
                return GestureDetector(
                  onTap: () => context.push('/tenant/property/${property.property.id}', extra: property),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                property.property.images.first,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[200]),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(property),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               property.property.title,
                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                             ),
                             const SizedBox(height: 4),
                             Row(
                               children: [
                                 const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                 const SizedBox(width: 4),
                                 Expanded(child: Text(property.property.location, style: const TextStyle(color: Colors.grey))),
                               ],
                             ),
                             const SizedBox(height: 12),
                             Text(
                               '${CurrencyFormatter.formatCFA(property.property.monthlyRentUnits.toDouble())}/mo',
                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                             ),
                           ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
