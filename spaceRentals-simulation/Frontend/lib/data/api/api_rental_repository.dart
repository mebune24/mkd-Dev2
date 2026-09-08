import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/utils/money.dart';
import '../../features/rentals/domain/rental.dart';
import '../../repositories/rental_repository.dart';
import '../../shared/models/enums.dart';

class ApiRentalRepository implements RentalRepository {
  final ApiClient _apiClient;

  ApiRentalRepository(this._apiClient);

  Rental _fromJson(Map<String, dynamic> json) {
    final property = json['property'] is Map
        ? Map<String, dynamic>.from(json['property'] as Map)
        : const <String, dynamic>{};
    final status = switch (json['status']?.toString()) {
      'active' => RentalStatus.active,
      'ended' => RentalStatus.ended,
      'disputed' => RentalStatus.disputed,
      _ => RentalStatus.pendingInitialPayment,
    };

    return Rental(
      id: json['id']?.toString() ?? '',
      leaseId: json['leaseId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyTitle: property['title']?.toString() ?? 'Rental property',
      tenantId: json['tenantId']?.toString() ?? '',
      landlordId: json['landlordId']?.toString() ?? '',
      status: status,
      monthlyRent: Money((json['monthlyRent'] as num?)?.toInt() ?? 0),
      activatedAt: DateTime.tryParse(json['activatedAt']?.toString() ?? ''),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Future<List<Rental>> _getList(String path) async {
    final response = await _apiClient.get<List<dynamic>>(path);
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load rentals');
    }
    return response.data!
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Rental> getRental(String rentalId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.rental(rentalId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Rental not found');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Rental> getRentalByLeaseId(String leaseId) async {
    final rentals = await getTenantRentals();
    return rentals.firstWhere((rental) => rental.leaseId == leaseId);
  }

  @override
  Future<List<Rental>> getTenantRentals() =>
      _getList('${ApiEndpoints.rentals}/tenant');

  @override
  Future<List<Rental>> getLandlordRentals({String? propertyId}) =>
      _getList('${ApiEndpoints.rentals}/landlord');

  @override
  Future<List<Rental>> getAllRentals({String? status}) =>
      _getList(ApiEndpoints.rentals);
}
