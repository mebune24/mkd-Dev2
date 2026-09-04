import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di_providers.dart';
import '../features/properties/domain/property.dart';
import '../shared/models/enums.dart';

// --- User Location Simulation --- //
// In a real app, this would use geolocator to get the device GPS.
// For this simulation, we mock the user's location to Yaoundé (Lat: 3.8480, Lng: 11.5021).
final userLocationProvider = Provider<Map<String, double>>((ref) {
  return {'latitude': 3.8480, 'longitude': 11.5021}; // Yaoundé
});

// --- Marketplace Providers --- //

/// Provides all published properties for the marketplace
final marketplaceListingsProvider = FutureProvider<List<PropertyWithListing>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final location = ref.watch(userLocationProvider);
  return repo.getMarketplaceListings(latitude: location['latitude'], longitude: location['longitude']);
});

/// Provides properties filtered by a specific category
final propertiesByCategoryProvider = FutureProvider.family<List<PropertyWithListing>, String>((ref, category) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final location = ref.watch(userLocationProvider);
  return repo.getMarketplaceListings(category: category, latitude: location['latitude'], longitude: location['longitude']);
});

/// Provides properties filtered by a search query
final propertiesBySearchProvider = FutureProvider.family<List<PropertyWithListing>, String>((ref, query) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final location = ref.watch(userLocationProvider);
  return repo.getMarketplaceListings(searchQuery: query, latitude: location['latitude'], longitude: location['longitude']);
});

/// Provides a single property by ID
final propertyDetailProvider = FutureProvider.family<PropertyWithListing, String>((ref, id) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getProperty(id);
});

// --- Landlord Providers --- //

/// Provides properties owned by the current landlord
final landlordPropertiesProvider = FutureProvider<List<PropertyWithListing>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getLandlordProperties();
});

// --- Recently Viewed --- //

class RecentlyViewedNotifier extends Notifier<List<PropertyWithListing>> {
  @override
  List<PropertyWithListing> build() => [];

  void addProperty(PropertyWithListing property) {
    final currentList = List<PropertyWithListing>.from(state);
    currentList.removeWhere((p) => p.property.id == property.property.id);
    currentList.insert(0, property);
    if (currentList.length > 10) currentList.removeLast();
    state = currentList;
  }
}

final recentlyViewedProvider = NotifierProvider<RecentlyViewedNotifier, List<PropertyWithListing>>(RecentlyViewedNotifier.new);

// Rotating recommended location provider
final recommendedLocationProvider = StreamProvider<String>((ref) async* {
  final locations = ['Yaoundé', 'Douala', 'Buea', 'Limbe'];
  int index = 0;
  
  yield locations[index];

  await for (final _ in Stream.periodic(const Duration(seconds: 60))) {
    index = (index + 1) % locations.length;
    yield locations[index];
  }
});
