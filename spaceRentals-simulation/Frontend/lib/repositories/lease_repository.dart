import '../features/leases/domain/lease.dart';

abstract class LeaseRepository {
  Future<Lease> getLease(String leaseId);
  Future<Lease> getLeaseByApplicationId(String applicationId);
  Future<Lease> signLease(String leaseId, {String? idempotencyKey});
  Future<List<Lease>> getTenantLeases();
  Future<List<Lease>> getLandlordLeases({String? propertyId});
}
