import '../../../shared/models/enums.dart';

class LeaseSignature {
  final String id;
  final String signerId;
  final Role signerRole;
  final SignatureStatus status;
  final DateTime? signedAt;

  const LeaseSignature({
    required this.id,
    required this.signerId,
    required this.signerRole,
    required this.status,
    this.signedAt,
  });
}

class Lease {
  final String id;
  final String applicationId;
  final String propertyId;
  final String propertyTitle;
  final String tenantId;
  final String landlordId;
  final LeaseStatus status;
  final String? leaseDocumentUrl;
  final LeaseSignature? tenantSignature;
  final LeaseSignature? landlordSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lease({
    required this.id,
    required this.applicationId,
    required this.propertyId,
    required this.propertyTitle,
    required this.tenantId,
    required this.landlordId,
    required this.status,
    this.leaseDocumentUrl,
    this.tenantSignature,
    this.landlordSignature,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFullySigned =>
      tenantSignature?.status == SignatureStatus.signed &&
      landlordSignature?.status == SignatureStatus.signed;

  bool needsSignatureFrom(Role role) {
    if (role == Role.tenant) {
      return status == LeaseStatus.pendingTenantSignature ||
          status == LeaseStatus.partiallySigned &&
              (tenantSignature == null ||
                  tenantSignature!.status == SignatureStatus.pending);
    }
    if (role == Role.landlord) {
      return status == LeaseStatus.pendingLandlordSignature ||
          status == LeaseStatus.partiallySigned &&
              (landlordSignature == null ||
                  landlordSignature!.status == SignatureStatus.pending);
    }
    return false;
  }
}
