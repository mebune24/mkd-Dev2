import '../../../shared/models/enums.dart';

/// The physical real-world asset.
class Property {
  final String id;
  final String landlordId;
  final String? acquisitionAgentId;
  final String acquisitionSource; // DIRECT, AGENT, LANDLORD, ADMIN, IMPORT
  final String title;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final int bathrooms;
  final int monthlyRentUnits; // FCFA, integer
  final int depositUnits;
  final List<String> images;
  final double areaSqM;
  final bool furnished;
  final int parkingSpaces;
  final List<String> amenities;
  final bool hasWater;
  final bool hasElectricity;
  final bool isFenced;
  final bool closeToRoad;
  final String securityMeans;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Property({
    required this.id,
    required this.landlordId,
    this.acquisitionAgentId,
    this.acquisitionSource = 'LANDLORD',
    required this.title,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.monthlyRentUnits,
    required this.depositUnits,
    required this.images,
    this.areaSqM = 0,
    this.furnished = false,
    this.parkingSpaces = 0,
    this.amenities = const [],
    this.hasWater = false,
    this.hasElectricity = false,
    this.isFenced = false,
    this.closeToRoad = false,
    this.securityMeans = 'None',
    this.category = 'Apartment',
    required this.createdAt,
    required this.updatedAt,
  });
}

/// The property's marketplace listing presence — separate from the physical asset.
class PropertyListing {
  final String id;
  final String propertyId;
  final PropertyAvailabilityStatus availabilityStatus;
  final DateTime lastAvailabilityConfirmedAt;
  final DateTime? publishedAt;
  final DateTime? unpublishedAt;

  const PropertyListing({
    required this.id,
    required this.propertyId,
    required this.availabilityStatus,
    required this.lastAvailabilityConfirmedAt,
    this.publishedAt,
    this.unpublishedAt,
  });

  bool get isPublished =>
      availabilityStatus == PropertyAvailabilityStatus.available ||
      availabilityStatus == PropertyAvailabilityStatus.confirmationDue ||
      availabilityStatus == PropertyAvailabilityStatus.stale;
}

/// Verification state for a property — read-only from backend.
class PropertyVerificationInfo {
  final PropertyVerificationLevel level;
  final DateTime? lastVerifiedAt;

  const PropertyVerificationInfo({
    required this.level,
    this.lastVerifiedAt,
  });

  bool get isVerified => level.index >= PropertyVerificationLevel.propertyVerified.index;

  String get levelLabel {
    switch (level) {
      case PropertyVerificationLevel.unverified:
        return 'Unverified';
      case PropertyVerificationLevel.documentsSubmitted:
        return 'Documents Submitted';
      case PropertyVerificationLevel.ownerVerified:
        return 'Owner Verified';
      case PropertyVerificationLevel.propertyVerified:
        return 'Space Verified';
      case PropertyVerificationLevel.physicallyInspected:
        return 'Space Inspected';
    }
  }

  String get freshnessSuffix {
    if (lastVerifiedAt == null) return '';
    final days = DateTime.now().difference(lastVerifiedAt!).inDays;
    if (days == 0) return 'verified today';
    if (days == 1) return 'verified yesterday';
    return 'verified $days days ago';
  }
}

/// Aggregated view used across most screens.
class PropertyWithListing {
  final Property property;
  final PropertyListing listing;
  final PropertyVerificationInfo verification;

  const PropertyWithListing({
    required this.property,
    required this.listing,
    required this.verification,
  });

  String get availabilityLabel {
    final days = DateTime.now()
        .difference(listing.lastAvailabilityConfirmedAt)
        .inDays;
    switch (listing.availabilityStatus) {
      case PropertyAvailabilityStatus.available:
        return days == 0 ? 'Available · confirmed today' : 'Available · confirmed $days days ago';
      case PropertyAvailabilityStatus.confirmationDue:
        return 'Confirmation due from landlord';
      case PropertyAvailabilityStatus.stale:
        return 'Listing may be outdated';
      case PropertyAvailabilityStatus.autoUnpublished:
        return 'Unpublished';
      case PropertyAvailabilityStatus.rented:
        return 'Rented';
    }
  }
}
