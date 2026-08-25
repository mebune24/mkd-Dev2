import '../features/rentals/domain/rental.dart';

abstract class RentalRepository {
  Future<Rental> getRental(String rentalId);
  Future<Rental> getRentalByLeaseId(String leaseId);
  Future<List<Rental>> getTenantRentals();
  Future<List<Rental>> getLandlordRentals({String? propertyId});
  Future<List<Rental>> getAllRentals({String? status});
}
