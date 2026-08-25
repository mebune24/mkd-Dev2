import 'package:uuid/uuid.dart';
import '../../features/leases/domain/lease.dart';
import '../../repositories/lease_repository.dart';
import '../../shared/models/enums.dart';

const _uuid = Uuid();

class MockLeaseRepository implements LeaseRepository {
  final List<Lease> _leases = [];

  @override
  Future<Lease> getLease(String leaseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _leases.firstWhere((l) => l.id == leaseId);
  }

  @override
  Future<Lease> getLeaseByApplicationId(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _leases.firstWhere((l) => l.applicationId == applicationId);
    } catch (e) {
      final lease = Lease(
        id: _uuid.v4(),
        applicationId: applicationId,
        propertyId: 'prop_1',
        propertyTitle: 'Mock Property',
        tenantId: 'tenant_1',
        landlordId: 'landlord_1',
        status: LeaseStatus.pendingTenantSignature,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _leases.add(lease);
      return lease;
    }
  }

  @override
  Future<Lease> signLease(String leaseId, {String? idempotencyKey}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _leases.indexWhere((l) => l.id == leaseId);
    if (index == -1) throw Exception('Lease not found');
    
    final currentLease = _leases[index];
    
    // In a real app, backend determines who signed based on auth token.
    // For this mock, if tenant hasn't signed, we sign for tenant.
    // Otherwise, we sign for landlord.
    LeaseSignature? tSig = currentLease.tenantSignature;
    LeaseSignature? lSig = currentLease.landlordSignature;
    LeaseStatus nextStatus = currentLease.status;

    if (tSig == null || tSig.status != SignatureStatus.signed) {
      tSig = LeaseSignature(
        id: _uuid.v4(), signerId: currentLease.tenantId,
        signerRole: Role.tenant, status: SignatureStatus.signed, signedAt: DateTime.now()
      );
      nextStatus = LeaseStatus.pendingLandlordSignature;
    } else if (lSig == null || lSig.status != SignatureStatus.signed) {
      lSig = LeaseSignature(
        id: _uuid.v4(), signerId: currentLease.landlordId,
        signerRole: Role.landlord, status: SignatureStatus.signed, signedAt: DateTime.now()
      );
      nextStatus = LeaseStatus.signed;
    }

    final updated = Lease(
      id: currentLease.id,
      applicationId: currentLease.applicationId,
      propertyId: currentLease.propertyId,
      propertyTitle: currentLease.propertyTitle,
      tenantId: currentLease.tenantId,
      landlordId: currentLease.landlordId,
      status: nextStatus,
      tenantSignature: tSig,
      landlordSignature: lSig,
      createdAt: currentLease.createdAt,
      updatedAt: DateTime.now(),
    );
    _leases[index] = updated;
    return updated;
  }

  @override
  Future<List<Lease>> getTenantLeases() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _leases.where((l) => l.tenantId == 'tenant_1').toList();
  }

  @override
  Future<List<Lease>> getLandlordLeases({String? propertyId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _leases.where((l) => l.landlordId == 'landlord_1').toList();
  }
}
