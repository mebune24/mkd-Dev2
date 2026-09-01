import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/properties/domain/property.dart';
import '../../repositories/property_repository.dart';
import '../../shared/models/enums.dart';

// ── Top-level parse helpers (required by compute()) ───────────────────────────

List<PropertyWithListing> _parsePropertyList(String responseBody) {
  final List<dynamic> data = json.decode(responseBody);
  return data.map((j) => _parsePropertyMap(j as Map<String, dynamic>)).toList();
}

PropertyWithListing _parsePropertyMap(Map<String, dynamic> j) {
  final property = Property(
    id: j['id'] ?? '',
    landlordId: j['landlordId'] ?? '',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    location: j['location'] ?? '',
    bedrooms: j['bedrooms'] ?? 0,
    bathrooms: j['bathrooms'] ?? 0,
    monthlyRentUnits: j['monthlyRent'] ?? 0,
    depositUnits: j['deposit'] ?? 0,
    images: _parseStringList(j['images']),
    category: j['category'] ?? 'Apartment',
    furnished: j['furnished'] ?? false,
    areaSqM: (j['areaSqM'] ?? 0).toDouble(),
    hasWater: j['hasWater'] ?? false,
    hasElectricity: j['hasElectricity'] ?? false,
    isFenced: j['isFenced'] ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
  );

  final statusStr = j['status'] ?? 'draft';
  PropertyAvailabilityStatus availStatus;
  switch (statusStr) {
    case 'available':
      availStatus = PropertyAvailabilityStatus.available;
      break;
    case 'rented':
      availStatus = PropertyAvailabilityStatus.rented;
      break;
    default:
      availStatus = PropertyAvailabilityStatus.autoUnpublished;
  }

  final listing = PropertyListing(
    id: j['id'] ?? '',
    propertyId: j['id'] ?? '',
    availabilityStatus: availStatus,
    lastAvailabilityConfirmedAt:
        DateTime.tryParse(j['lastConfirmedAvailableAt'] ?? '') ?? DateTime.now(),
    publishedAt: DateTime.tryParse(j['createdAt'] ?? ''),
  );

  final vm = j['propertyVerification'];
  PropertyVerificationLevel level = PropertyVerificationLevel.unverified;
  if (vm != null) {
    final lvl = vm['level'];
    if (lvl == 1) level = PropertyVerificationLevel.documentsSubmitted;
    else if (lvl == 2) level = PropertyVerificationLevel.ownerVerified;
    else if (lvl == 3) level = PropertyVerificationLevel.propertyVerified;
    else if (lvl == 4) level = PropertyVerificationLevel.physicallyInspected;
  }

  return PropertyWithListing(
    property: property,
    listing: listing,
    verification: PropertyVerificationInfo(level: level),
  );
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    try {
      final parsed = json.decode(value);
      if (parsed is List) return parsed.map((e) => e.toString()).toList();
    } catch (_) {}
    return [];
  }
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

// ── Repository ────────────────────────────────────────────────────────────────

class ApiPropertyRepository implements PropertyRepository {
  final ApiClient _apiClient;
  ApiPropertyRepository(this._apiClient);

  // ── Helper: unwrap ApiResponse or throw ──────────────────────────────────
  T _unwrap<T>(ApiResponse<dynamic> response, T Function(dynamic data) parse) {
    if (response.isSuccess) return parse(response.data);
    throw Exception(response.error?.message ?? 'API error');
  }

  @override
  Future<List<PropertyWithListing>> getMarketplaceListings({
    String? searchQuery,
    String? category,
    String? location,
  }) async {
    final hasFilters = (searchQuery != null && searchQuery.isNotEmpty) ||
        (location != null && location.isNotEmpty) ||
        (category != null && category != 'All');

    final String path;
    final Map<String, dynamic>? queryParams;

    if (hasFilters) {
      path = '${ApiEndpoints.properties}/search';
      queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;
      if (location != null && location.isNotEmpty) queryParams['location'] = location;
      if (category != null && category != 'All') queryParams['category'] = category;
    } else {
      path = ApiEndpoints.properties;
      queryParams = null;
    }

    final response = await _apiClient.get(path, queryParameters: queryParams);
    return _unwrap(response, (data) => _parsePropertyList(json.encode(data)));
  }

  @override
  Future<PropertyWithListing> getProperty(String propertyId) async {
    final response = await _apiClient.get(ApiEndpoints.property(propertyId));
    return _unwrap(response, (data) => _parsePropertyMap(data as Map<String, dynamic>));
  }

  @override
  Future<List<PropertyWithListing>> getLandlordProperties() async {
    final response = await _apiClient.get('${ApiEndpoints.properties}/my/listings');
    return _unwrap(response, (data) => _parsePropertyList(json.encode(data)));
  }

  @override
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
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.properties,
      data: {
        'title': title,
        'description': description,
        'location': location,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'monthlyRent': monthlyRentUnits,
        'deposit': depositUnits,
        'images': imageUrls,
        'category': category,
        'amenities': amenities,
      },
    );
    return _unwrap(response, (data) => _parsePropertyMap(data as Map<String, dynamic>).property);
  }

  @override
  Future<PropertyListing> confirmAvailability(String propertyId) async {
    final response = await _apiClient.patch(ApiEndpoints.confirmAvailability(propertyId));
    return _unwrap(response, (data) => _parsePropertyMap(data as Map<String, dynamic>).listing);
  }

  @override
  Future<PropertyVerificationInfo> updateVerificationLevel(
      String propertyId, PropertyVerificationLevel level) async {
    throw UnimplementedError('updateVerificationLevel not implemented in API');
  }

  @override
  Future<PropertyListing> unpublishListing(String propertyId) async {
    final response = await _apiClient.patch('${ApiEndpoints.properties}/$propertyId/unpublish');
    return _unwrap(response, (data) => _parsePropertyMap(data as Map<String, dynamic>).listing);
  }

  @override
  Future<PropertyListing> republishListing(String propertyId) async {
    final response = await _apiClient.patch('${ApiEndpoints.properties}/$propertyId/publish');
    return _unwrap(response, (data) => _parsePropertyMap(data as Map<String, dynamic>).listing);
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    final response = await _apiClient.delete(ApiEndpoints.property(propertyId));
    if (!response.isSuccess) {
      throw Exception(response.error?.message ?? 'Failed to delete property');
    }
  }
}
