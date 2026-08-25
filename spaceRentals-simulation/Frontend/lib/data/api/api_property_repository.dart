import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_endpoints.dart';
import '../../features/properties/domain/property.dart';
import '../../repositories/property_repository.dart';
import '../../shared/models/enums.dart';

// Top-level function required by compute()
List<PropertyWithListing> _parsePropertyList(String responseBody) {
  final List<dynamic> data = json.decode(responseBody);
  return data.map((j) => _parsePropertyMap(j as Map<String, dynamic>)).toList();
}

PropertyWithListing _parsePropertyMap(Map<String, dynamic> jsonMap) {
  final property = Property(
    id: jsonMap['id'],
    landlordId: jsonMap['landlordId'],
    title: jsonMap['title'],
    description: jsonMap['description'],
    location: jsonMap['location'],
    bedrooms: jsonMap['bedrooms'] ?? 0,
    bathrooms: jsonMap['bathrooms'] ?? 0,
    monthlyRentUnits: jsonMap['monthlyRent'] ?? 0,
    depositUnits: jsonMap['deposit'] ?? 0,
    images: _parseStringListStatic(jsonMap['images']),
    category: jsonMap['category'] ?? 'Apartment',
    furnished: jsonMap['furnished'] ?? false,
    areaSqM: (jsonMap['areaSqM'] ?? 0).toDouble(),
    hasWater: jsonMap['hasWater'] ?? false,
    hasElectricity: jsonMap['hasElectricity'] ?? false,
    isFenced: jsonMap['isFenced'] ?? false,
    createdAt: DateTime.tryParse(jsonMap['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(jsonMap['updatedAt'] ?? '') ?? DateTime.now(),
  );

  final statusStr = jsonMap['status'] ?? 'draft';
  PropertyAvailabilityStatus availStatus = PropertyAvailabilityStatus.stale;
  if (statusStr == 'available') availStatus = PropertyAvailabilityStatus.available;
  if (statusStr == 'draft' || statusStr == 'auto_unpublished') availStatus = PropertyAvailabilityStatus.autoUnpublished;
  if (statusStr == 'rented') availStatus = PropertyAvailabilityStatus.rented;

  final listing = PropertyListing(
    id: jsonMap['id'],
    propertyId: jsonMap['id'],
    availabilityStatus: availStatus,
    lastAvailabilityConfirmedAt: DateTime.tryParse(jsonMap['lastConfirmedAvailableAt'] ?? '') ?? DateTime.now(),
    publishedAt: DateTime.tryParse(jsonMap['createdAt'] ?? ''),
  );

  final verificationMap = jsonMap['propertyVerification'];
  PropertyVerificationLevel level = PropertyVerificationLevel.unverified;
  if (verificationMap != null) {
    final lvl = verificationMap['level'];
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

List<String> _parseStringListStatic(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    try {
      final parsed = json.decode(value);
      if (parsed is List) return parsed.map((e) => e.toString()).toList();
    } catch (_) { return []; }
  }
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

class ApiPropertyRepository implements PropertyRepository {
  final http.Client _client = http.Client();
  
  // You would ideally pass this from an Auth provider
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  @override
  Future<List<PropertyWithListing>> getMarketplaceListings({
    String? searchQuery,
    String? category,
    String? location,
  }) async {
    final hasFilters = (searchQuery != null && searchQuery.isNotEmpty) ||
        (location != null && location.isNotEmpty) ||
        (category != null && category != 'All');

    Uri uri;
    if (hasFilters) {
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;
      else if (location != null && location.isNotEmpty) queryParams['q'] = location;
      if (category != null && category != 'All') queryParams['category'] = category;
      uri = Uri.parse('${ApiEndpoints.properties}/search').replace(queryParameters: queryParams);
    } else {
      // Load all available properties for home screen
      uri = Uri.parse(ApiEndpoints.properties);
    }

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      // Parse on a background isolate to avoid jank
      return compute(_parsePropertyList, response.body);
    } else {
      throw Exception('Failed to load properties');
    }
  }

  @override
  Future<PropertyWithListing> getProperty(String propertyId) async {
    final uri = Uri.parse('${ApiEndpoints.properties}/$propertyId');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return compute(_parsePropertyMap, json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Property not found');
    }
  }

  @override
  Future<List<PropertyWithListing>> getLandlordProperties() async {
    final uri = Uri.parse('${ApiEndpoints.properties}/my/listings');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return compute(_parsePropertyList, response.body);
    } else {
      throw Exception('Failed to load landlord properties');
    }
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
    final uri = Uri.parse(ApiEndpoints.properties);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: json.encode({
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
      }),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return _parseProperty(data).property;
    } else {
      throw Exception('Failed to submit property');
    }
  }

  @override
  Future<PropertyListing> confirmAvailability(String propertyId) async {
    final uri = Uri.parse(ApiEndpoints.confirmAvailability(propertyId));
    final response = await _client.patch(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseProperty(data).listing;
    } else {
      throw Exception('Failed to confirm availability');
    }
  }

  @override
  Future<PropertyVerificationInfo> updateVerificationLevel(String propertyId, PropertyVerificationLevel level) async {
    // Admin only route in typical setups
    throw UnimplementedError('updateVerificationLevel not implemented in API');
  }

  @override
  Future<PropertyListing> unpublishListing(String propertyId) async {
    final uri = Uri.parse('${ApiEndpoints.properties}/$propertyId/unpublish');
    final response = await _client.patch(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseProperty(data).listing;
    } else {
      throw Exception('Failed to unpublish listing');
    }
  }

  @override
  Future<PropertyListing> republishListing(String propertyId) async {
    final uri = Uri.parse('${ApiEndpoints.properties}/$propertyId/publish');
    final response = await _client.patch(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseProperty(data).listing;
    } else {
      throw Exception('Failed to republish listing');
    }
  }

}
