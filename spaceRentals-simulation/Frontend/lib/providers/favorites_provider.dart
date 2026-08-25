import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/properties/domain/property.dart';

class FavoritesNotifier extends Notifier<List<PropertyWithListing>> {
  @override
  List<PropertyWithListing> build() {
    return [];
  }

  void toggleFavorite(PropertyWithListing property) {
    if (state.any((p) => p.property.id == property.property.id)) {
      state = state.where((p) => p.property.id != property.property.id).toList();
    } else {
      state = [...state, property];
    }
  }

  bool isFavorite(String propertyId) {
    return state.any((p) => p.property.id == propertyId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<PropertyWithListing>>(() {
  return FavoritesNotifier();
});
