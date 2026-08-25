import '../../../shared/models/enums.dart';

class Application {
  final String id;
  final String tenantId;
  final String tenantName;
  final String propertyId;
  final String propertyTitle;
  final String landlordId;
  final ApplicationStatus status;
  final String? coverLetter;
  final String? landlordNote;
  final DateTime submittedAt;
  final DateTime updatedAt;

  final String? nationalIdUrl;
  final String? proofOfIncomeUrl;

  const Application({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.propertyId,
    required this.propertyTitle,
    required this.landlordId,
    required this.status,
    this.coverLetter,
    this.nationalIdUrl,
    this.proofOfIncomeUrl,
    this.landlordNote,
    required this.submittedAt,
    required this.updatedAt,
  });

  Application copyWith({
    ApplicationStatus? status,
    String? landlordNote,
    String? nationalIdUrl,
    String? proofOfIncomeUrl,
    DateTime? updatedAt,
  }) {
    return Application(
      id: id,
      tenantId: tenantId,
      tenantName: tenantName,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      landlordId: landlordId,
      status: status ?? this.status,
      coverLetter: coverLetter,
      nationalIdUrl: nationalIdUrl ?? this.nationalIdUrl,
      proofOfIncomeUrl: proofOfIncomeUrl ?? this.proofOfIncomeUrl,
      landlordNote: landlordNote ?? this.landlordNote,
      submittedAt: submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canBeWithdrawn =>
      status == ApplicationStatus.submitted || status == ApplicationStatus.underReview;
}

class SubmitApplicationRequest {
  final String propertyId;
  final String landlordId;
  final String? coverLetter;
  final String? nationalIdUrl;
  final String? proofOfIncomeUrl;
  final String? idempotencyKey;

  const SubmitApplicationRequest({
    required this.propertyId,
    required this.landlordId,
    this.coverLetter,
    this.nationalIdUrl,
    this.proofOfIncomeUrl,
    this.idempotencyKey,
  });
}
