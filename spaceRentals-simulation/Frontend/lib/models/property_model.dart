/// Freshness lifecycle for a property listing
enum PropertyFreshnessStatus {
  available,         // Landlord confirmed availability within 7 days
  confirmationDue,   // 7+ days without confirmation — landlord prompted
  stale,             // 14+ days — ranking drops, yellow warning badge
  unpublished,       // 30+ days — auto-removed from feed
}

class PropertyWithListing {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final int bedrooms;
  final int bathrooms;
  final double monthlyRent;
  final double deposit;
  final List<String> images;

  // Verification
  final int verificationLevel; // 0: Unverified, 1: Docs Submitted, 2: Owner Verified, 3: Property Verified, 4: Physically Inspected
  final DateTime? lastVerifiedAt;

  // Freshness (separate from verification — tracks availability, not authenticity)
  final DateTime? lastAvailabilityConfirmedAt;
  final PropertyFreshnessStatus freshnessStatus;

  final String status;
  final String category;

  // Attribution — renamed from submittedByAgentId for clarity
  final String? acquisitionAgentId;

  // Details & specs
  final double rating;
  final double areaSqM;
  final bool furnished;
  final int parkingSpaces;
  final int floor;
  final int totalFloors;
  final int yearBuilt;
  final List<String> nearbyAmenities;

  // Amenities
  final bool hasWater;
  final bool isFenced;
  final bool closeToRoad;
  final bool hasElectricity;
  final String securityMeans;

  // Rental terms
  final List<String> rentalAgreementTerms;

  // Media
  final List<String> floorPlanImages;
  final List<String> videoUrls;

  PropertyWithListing({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.monthlyRent,
    required this.deposit,
    required this.images,
    this.verificationLevel = 0,
    this.lastVerifiedAt,
    this.lastAvailabilityConfirmedAt,
    this.freshnessStatus = PropertyFreshnessStatus.available,
    required this.status,
    this.category = 'Apartments',
    this.acquisitionAgentId,
    this.rating = 0.0,
    this.areaSqM = 0.0,
    this.furnished = false,
    this.parkingSpaces = 0,
    this.floor = 0,
    this.totalFloors = 1,
    this.yearBuilt = 0,
    this.nearbyAmenities = const [],
    this.hasWater = false,
    this.isFenced = false,
    this.closeToRoad = false,
    this.hasElectricity = false,
    this.securityMeans = 'None',
    this.rentalAgreementTerms = const [],
    this.floorPlanImages = const [],
    this.videoUrls = const [],
  });

  PropertyWithListing copyWith({
    String? id,
    String? landlordId,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? monthlyRent,
    double? deposit,
    List<String>? images,
    int? verificationLevel,
    DateTime? lastVerifiedAt,
    DateTime? lastAvailabilityConfirmedAt,
    PropertyFreshnessStatus? freshnessStatus,
    String? status,
    String? category,
    String? acquisitionAgentId,
    double? rating,
    double? areaSqM,
    bool? furnished,
    int? parkingSpaces,
    int? floor,
    int? totalFloors,
    int? yearBuilt,
    List<String>? nearbyAmenities,
    bool? hasWater,
    bool? isFenced,
    bool? closeToRoad,
    bool? hasElectricity,
    String? securityMeans,
    List<String>? rentalAgreementTerms,
    List<String>? floorPlanImages,
    List<String>? videoUrls,
  }) {
    return PropertyWithListing(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      deposit: deposit ?? this.deposit,
      images: images ?? this.images,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      lastAvailabilityConfirmedAt: lastAvailabilityConfirmedAt ?? this.lastAvailabilityConfirmedAt,
      freshnessStatus: freshnessStatus ?? this.freshnessStatus,
      status: status ?? this.status,
      category: category ?? this.category,
      acquisitionAgentId: acquisitionAgentId ?? this.acquisitionAgentId,
      rating: rating ?? this.rating,
      areaSqM: areaSqM ?? this.areaSqM,
      furnished: furnished ?? this.furnished,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      floor: floor ?? this.floor,
      totalFloors: totalFloors ?? this.totalFloors,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      nearbyAmenities: nearbyAmenities ?? this.nearbyAmenities,
      hasWater: hasWater ?? this.hasWater,
      isFenced: isFenced ?? this.isFenced,
      closeToRoad: closeToRoad ?? this.closeToRoad,
      hasElectricity: hasElectricity ?? this.hasElectricity,
      securityMeans: securityMeans ?? this.securityMeans,
      rentalAgreementTerms: rentalAgreementTerms ?? this.rentalAgreementTerms,
      floorPlanImages: floorPlanImages ?? this.floorPlanImages,
      videoUrls: videoUrls ?? this.videoUrls,
    );
  }
}
