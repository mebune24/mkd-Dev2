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
        title: 'Modern 2BR Apartment - Bastos', description: 'Bright, modern apartment in the heart of Bastos. Perfect for professionals.',
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
        title: 'Studio - Melen', description: 'Cozy studio near the University of Yaoundé I.',
        location: 'Melen, Yaoundé', bedrooms: 1, bathrooms: 1,
        monthlyRentUnits: 75000, depositUnits: 150000,
        images: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'],
        category: 'Studio', furnished: false, areaSqM: 35,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 15)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_2', propertyId: 'prop_2',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 15)),
      ),
      verification: const PropertyVerificationInfo(level: PropertyVerificationLevel.ownerVerified),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_3', landlordId: 'landlord_2',
        title: 'Family Villa - Omnisports', description: 'Spacious 4-bedroom villa with a private garden and 2 parking spaces.',
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
    PropertyWithListing(
      property: Property(
        id: 'prop_4', landlordId: 'landlord_3',
        title: '3BR Apartment - Bonanjo, Douala', description: 'Modern apartment in Douala\'s business district. Close to the port.',
        location: 'Bonanjo, Douala', bedrooms: 3, bathrooms: 2,
        monthlyRentUnits: 200000, depositUnits: 400000,
        images: ['https://images.unsplash.com/photo-1502672260266-1c1de2d9d1ab?w=800'],
        category: 'Apartment', furnished: true, areaSqM: 110,
        hasWater: true, hasElectricity: true, isFenced: true,
        createdAt: now.subtract(const Duration(days: 10)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_4', propertyId: 'prop_4',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 10)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.propertyVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 5)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_5', landlordId: 'landlord_3',
        title: 'Student Studio - Buea', description: 'Affordable student housing near the University of Buea campus.',
        location: 'Molyko, Buea', bedrooms: 1, bathrooms: 1,
        monthlyRentUnits: 45000, depositUnits: 90000,
        images: ['https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800'],
        category: 'Studio', furnished: false, areaSqM: 28,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 5)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_5', propertyId: 'prop_5',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(hours: 12)),
        publishedAt: now.subtract(const Duration(days: 5)),
      ),
      verification: const PropertyVerificationInfo(level: PropertyVerificationLevel.ownerVerified),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_6', landlordId: 'landlord_4',
        title: 'Luxury Villa - Bonapriso, Douala', description: 'Executive 5-bedroom villa with pool, gym, and 24/7 security.',
        location: 'Bonapriso, Douala', bedrooms: 5, bathrooms: 4,
        monthlyRentUnits: 750000, depositUnits: 1500000,
        images: ['https://images.unsplash.com/photo-1613977257592-4871e5fcd7c4?w=800'],
        category: 'Villa', furnished: true, areaSqM: 450,
        hasWater: true, hasElectricity: true, isFenced: true, parkingSpaces: 4,
        createdAt: now.subtract(const Duration(days: 60)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_6', propertyId: 'prop_6',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 60)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.physicallyInspected,
        lastVerifiedAt: now.subtract(const Duration(days: 30)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_7', landlordId: 'landlord_4',
        title: 'Commercial Space - Akwa, Douala', description: 'Prime office space in Akwa business hub. Ideal for small businesses.',
        location: 'Akwa, Douala', bedrooms: 0, bathrooms: 2,
        monthlyRentUnits: 300000, depositUnits: 600000,
        images: ['https://images.unsplash.com/photo-1497366216548-37526070297c?w=800'],
        category: 'Commercial', furnished: false, areaSqM: 150,
        hasWater: true, hasElectricity: true, isFenced: true,
        createdAt: now.subtract(const Duration(days: 20)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_7', propertyId: 'prop_7',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 4)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.propertyVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 10)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_8', landlordId: 'landlord_5',
        title: 'Land Plot - Limbe', description: '500 sqm fenced land with title deed. Near the beach.',
        location: 'Mile 4, Limbe', bedrooms: 0, bathrooms: 0,
        monthlyRentUnits: 0, depositUnits: 5000000,
        images: ['https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800'],
        category: 'Land', furnished: false, areaSqM: 500,
        hasWater: false, hasElectricity: false, isFenced: true,
        createdAt: now.subtract(const Duration(days: 90)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_8', propertyId: 'prop_8',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 90)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.ownerVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 20)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_9', landlordId: 'landlord_5',
        title: '1BR Apartment - Deido, Douala', description: 'Clean, affordable 1-bedroom apartment with balcony and city views.',
        location: 'Deido, Douala', bedrooms: 1, bathrooms: 1,
        monthlyRentUnits: 85000, depositUnits: 170000,
        images: ['https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800'],
        category: 'Apartment', furnished: false, areaSqM: 55,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 7)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_9', propertyId: 'prop_9',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(hours: 6)),
        publishedAt: now.subtract(const Duration(days: 7)),
      ),
      verification: const PropertyVerificationInfo(level: PropertyVerificationLevel.documentsSubmitted),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_10', landlordId: 'landlord_6',
        title: 'Furnished Studio - Biyem-Assi', description: 'Fully furnished studio in a quiet, secure neighbourhood.',
        location: 'Biyem-Assi, Yaoundé', bedrooms: 1, bathrooms: 1,
        monthlyRentUnits: 60000, depositUnits: 120000,
        images: ['https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800'],
        category: 'Studio', furnished: true, areaSqM: 32,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 3)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_10', propertyId: 'prop_10',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(hours: 2)),
        publishedAt: now.subtract(const Duration(days: 3)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.propertyVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 2)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_11', landlordId: 'landlord_6',
        title: 'Executive Villa - Santa Barbara, Yaoundé', description: 'Prestigious 4BR villa in Yaoundé\'s most sought-after neighbourhood.',
        location: 'Santa Barbara, Yaoundé', bedrooms: 4, bathrooms: 3,
        monthlyRentUnits: 500000, depositUnits: 1000000,
        images: ['https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800'],
        category: 'Villa', furnished: true, areaSqM: 320,
        hasWater: true, hasElectricity: true, isFenced: true, parkingSpaces: 3,
        createdAt: now.subtract(const Duration(days: 25)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_11', propertyId: 'prop_11',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now.subtract(const Duration(days: 2)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.physicallyInspected,
        lastVerifiedAt: now.subtract(const Duration(days: 10)),
      ),
    ),
    PropertyWithListing(
      property: Property(
        id: 'prop_12', landlordId: 'landlord_7',
        title: '2BR Apartment - Ndokoti, Douala', description: 'Modern apartment near Ndokoti market, close to all amenities.',
        location: 'Ndokoti, Douala', bedrooms: 2, bathrooms: 1,
        monthlyRentUnits: 110000, depositUnits: 220000,
        images: ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800'],
        category: 'Apartment', furnished: false, areaSqM: 70,
        hasWater: true, hasElectricity: true,
        createdAt: now.subtract(const Duration(days: 2)), updatedAt: now,
      ),
      listing: PropertyListing(
        id: 'listing_12', propertyId: 'prop_12',
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: now,
        publishedAt: now.subtract(const Duration(days: 2)),
      ),
      verification: PropertyVerificationInfo(
        level: PropertyVerificationLevel.propertyVerified,
        lastVerifiedAt: now.subtract(const Duration(days: 1)),
      ),
    ),
  ];
}
