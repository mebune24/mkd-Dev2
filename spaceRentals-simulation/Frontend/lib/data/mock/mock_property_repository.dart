import 'package:uuid/uuid.dart';
import '../../features/properties/domain/property.dart';
import '../../repositories/property_repository.dart';
import '../../shared/models/enums.dart';

const _uuid = Uuid();

class MockPropertyRepository implements PropertyRepository {
  final List<PropertyWithListing> _properties = _seedProperties();

  @override
  Future<List<PropertyWithListing>> getMarketplaceListings({String? searchQuery, String? category, String? location}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    var results = _properties.where((p) => p.listing.isPublished).toList();
    if (category != null && category != 'All') {
      results = results.where((p) => p.property.category == category).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((p) =>
          p.property.title.toLowerCase().contains(q) ||
          p.property.location.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  @override
  Future<PropertyWithListing> getProperty(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _properties.firstWhere((p) => p.property.id == propertyId);
  }

  @override
  Future<List<PropertyWithListing>> getLandlordProperties() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_properties.where((p) => p.property.landlordId == 'landlord_1'));
  }

  @override
  Future<Property> submitProperty({
    required String title, required String description, required String location,
    required int bedrooms, required int bathrooms, required int monthlyRentUnits,
    required int depositUnits, required List<String> imageUrls, required String category,
    required Map<String, dynamic> amenities,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final now = DateTime.now();
    final property = Property(
      id: _uuid.v4(), landlordId: 'landlord_1', title: title,
      description: description, location: location, bedrooms: bedrooms,
      bathrooms: bathrooms, monthlyRentUnits: monthlyRentUnits,
      depositUnits: depositUnits, images: imageUrls, category: category,
      createdAt: now, updatedAt: now,
    );
    _properties.add(PropertyWithListing(
      property: property,
      listing: PropertyListing(
        id: _uuid.v4(), propertyId: property.id,
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now, publishedAt: now,
      ),
      verification: const PropertyVerificationInfo(level: PropertyVerificationLevel.unverified),
    ));
    return property;
  }

  @override
  Future<PropertyListing> confirmAvailability(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _properties.indexWhere((p) => p.property.id == propertyId);
    final now = DateTime.now();
    final updated = PropertyListing(
      id: _properties[index].listing.id,
      propertyId: propertyId,
      availabilityStatus: PropertyAvailabilityStatus.available,
      lastAvailabilityConfirmedAt: now,
      publishedAt: _properties[index].listing.publishedAt,
    );
    _properties[index] = PropertyWithListing(
      property: _properties[index].property,
      listing: updated,
      verification: _properties[index].verification,
    );
    return updated;
  }

  @override
  Future<PropertyVerificationInfo> updateVerificationLevel(String propertyId, PropertyVerificationLevel level) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _properties.indexWhere((p) => p.property.id == propertyId);
    final updated = PropertyVerificationInfo(level: level, lastVerifiedAt: DateTime.now());
    _properties[index] = PropertyWithListing(
      property: _properties[index].property,
      listing: _properties[index].listing,
      verification: updated,
    );
    return updated;
  }

  @override
  Future<PropertyListing> unpublishListing(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _properties.indexWhere((p) => p.property.id == propertyId);
    final now = DateTime.now();
    final updated = PropertyListing(
      id: _properties[index].listing.id, propertyId: propertyId,
      availabilityStatus: PropertyAvailabilityStatus.autoUnpublished,
      lastAvailabilityConfirmedAt: _properties[index].listing.lastAvailabilityConfirmedAt,
      unpublishedAt: now,
    );
    _properties[index] = PropertyWithListing(
      property: _properties[index].property, listing: updated,
      verification: _properties[index].verification,
    );
    return updated;
  }

  @override
  Future<PropertyListing> republishListing(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _properties.indexWhere((p) => p.property.id == propertyId);
    final now = DateTime.now();
    final updated = PropertyListing(
      id: _properties[index].listing.id, propertyId: propertyId,
      availabilityStatus: PropertyAvailabilityStatus.available,
      lastAvailabilityConfirmedAt: now, publishedAt: now,
    );
    _properties[index] = PropertyWithListing(
      property: _properties[index].property, listing: updated,
      verification: _properties[index].verification,
    );
    return updated;
  }
}

List<PropertyWithListing> _seedProperties() {
  final now = DateTime.now();
  return [
    PropertyWithListing(
      property: Property(
        id: 'prop_1', landlordId: 'landlord_1',
        title: 'Modern 2BR Apartment - Bastos', description: 'Bright, modern apartment in the heart of Bastos.',
        location: 'Bastos, Yaoundé', bedrooms: 2, bathrooms: 1,
        monthlyRentUnits: 150000, depositUnits: 300000,
        images: ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'],
        category: 'Apartment', furnished: true, areaSqM: 85,
        hasWater: true, hasElectricity: true, isFenced: true,
        createdAt: now.subtract(const Duration(days: 30)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_1', propertyId: 'prop_1',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 2)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.propertyVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 7)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_2', landlordId: 'landlord_1',
        title: 'Studio - Melen', description: 'Cozy studio apartment near the university.',
        location: 'Melen, Yaoundé', bedrooms: 1, bathrooms: 1,
        monthlyRentUnits: 75000, depositUnits: 150000,
        images: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'],
        category: 'Studio', furnished: false, areaSqM: 35,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 15)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_2', propertyId: 'prop_2',
        availabilityStatus: PropertyAvailabilityStatus.confirmationDue,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 15)),
      ),
      verification: const PropertyVerificationInfo(level: PropertyVerificationLevel.ownerVerified),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_3', landlordId: 'landlord_2',
        title: 'Family Villa - Omnisports', description: 'Spacious 4-bedroom villa with garden.',
        location: 'Omnisports, Yaoundé', bedrooms: 4, bathrooms: 3,
        monthlyRentUnits: 350000, depositUnits: 700000,
        images: ['https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'],
        category: 'Villa', furnished: true, areaSqM: 220,
        hasWater: true, hasElectricity: true, isFenced: true, parkingSpaces: 2,
        createdAt: now.subtract(const Duration(days: 45)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_3', propertyId: 'prop_3',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 45)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.physicallyInspected,
        lastVerifiedAt: now.subtract(const Duration(days: 14)),
      ),
    ),
  ];
}
