import '../features/leases/domain/lease.dart';

abstract class LeaseRepository {
  Future<Lease> getLease(String leaseId);
  Future<Lease> getLeaseByApplicationId(String applicationId);
  Future<Lease> signLease(String leaseId, {String? idempotencyKey});
  Future<Lease> acceptLease(String leaseId);
  Future<Lease> rejectLease(String leaseId, {String? reason});
  Future<List<Lease>> getTenantLeases();
  Future<List<Lease>> getLandlordLeases({String? propertyId});
}
