import '../features/properties/domain/property.dart';
import '../shared/models/enums.dart';

abstract class PropertyRepository {
  Future<List<PropertyWithListing>> getMarketplaceListings({
    String? searchQuery,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
  });
  Future<PropertyWithListing> getProperty(String propertyId);
  Future<List<PropertyWithListing>> getLandlordProperties();
  Future<Property> submitProperty({
    required String title,
    required String description,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required int monthlyRentUnits,
    required int depositUnits,
    required List<String> imageUrls,
    required String category,
    required Map<String, dynamic> amenities,
  });
  Future<PropertyListing> confirmAvailability(String propertyId);
  Future<PropertyVerificationInfo> updateVerificationLevel(
      String propertyId, PropertyVerificationLevel level);
  Future<PropertyListing> unpublishListing(String propertyId);
  Future<void> deleteProperty(String propertyId);
  Future<PropertyListing> republishListing(String propertyId);
}
