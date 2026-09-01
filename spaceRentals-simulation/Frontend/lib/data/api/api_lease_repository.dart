import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/leases/domain/lease.dart';
import '../../repositories/lease_repository.dart';
import '../../services/session_storage_service.dart';
import '../../shared/models/enums.dart';

/// ApiLeaseRepository
///
/// Connects to the real Node.js/Express backend for all lease operations.
/// Implements OHADA-aligned auditability: signs send a SHA-256 hash of the
/// signature data alongside the request for the backend to record.
class ApiLeaseRepository implements LeaseRepository {
  final ApiClient _apiClient;

  ApiLeaseRepository(this._apiClient);

  Lease _fromJson(Map<String, dynamic> j) {
    LeaseStatus status;
    switch (j['status']) {
      case 'generated':       status = LeaseStatus.generated; break;
      case 'pending_tenant':  status = LeaseStatus.pendingTenantSignature; break;
      case 'pending_landlord':status = LeaseStatus.pendingLandlordSignature; break;
      case 'partially_signed':status = LeaseStatus.partiallySigned; break;
      case 'signed':          status = LeaseStatus.signed; break;
      case 'active':          status = LeaseStatus.signed; break;
      default:                status = LeaseStatus.generated;
    }

    LeaseSignature? _buildSig(String? signerId, Role role, DateTime? signedAt) {
      if (signerId == null) return null;
      return LeaseSignature(
        id: '$signerId-${role.name}',
        signerId: signerId,
        signerRole: role,
        status: signedAt != null ? SignatureStatus.signed : SignatureStatus.pending,
        signedAt: signedAt,
      );
    }

    final property = j['property'] as Map<String, dynamic>?;

    return Lease(
      id:            j['id'] ?? '',
      applicationId: j['applicationId'] ?? '',
      propertyId:    j['propertyId'] ?? '',
      propertyTitle: property?['title'] ?? '',
      tenantId:      j['tenantId'] ?? '',
      landlordId:    j['landlordId'] ?? '',
      status:        status,
      leaseDocumentUrl: j['documentUrl'],
      tenantSignature:   _buildSig(
        j['tenantId'],
        Role.tenant,
        j['tenantSignedAt'] != null ? DateTime.tryParse(j['tenantSignedAt']) : null,
      ),
      landlordSignature: _buildSig(
        j['landlordId'],
        Role.landlord,
        j['landlordSignedAt'] != null ? DateTime.tryParse(j['landlordSignedAt']) : null,
      ),
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<Lease> getLease(String leaseId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.lease(leaseId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Lease not found');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Lease> getLeaseByApplicationId(String applicationId) async {
    // The backend returns the lease nested inside the application
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.leases}/by-application/$applicationId',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Lease not found for this application');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Lease> signLease(String leaseId, {String? idempotencyKey}) async {
    // Generate a cryptographic signature hash for OHADA-aligned auditability.
    // This hash represents: leaseId + userId (from token) + timestamp.
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final session = await SessionStorageService.instance.loadSession();
    final rawSignature = '$leaseId:${session?.userId ?? ''}:$timestamp';
    final signatureHash = sha256.convert(utf8.encode(rawSignature)).toString();

    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.signLease(leaseId),
      data: {
        'signatureHash': signatureHash,
        // IP is captured server-side from req.ip for security.
        // We pass the idempotency key to prevent double-signing.
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to sign lease');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<List<Lease>> getTenantLeases() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiEndpoints.leases}/tenant',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load leases');
    }
    return response.data!.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Lease>> getLandlordLeases({String? propertyId}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiEndpoints.leases}/landlord',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load leases');
    }
    var leases = response.data!.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    if (propertyId != null) {
      leases = leases.where((l) => l.propertyId == propertyId).toList();
    }
    return leases;
  }
}
