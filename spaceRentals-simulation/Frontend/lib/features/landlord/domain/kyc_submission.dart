class KYCSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final bool isPremium;
  final Map<String, String> documents;
  final String idType; // 'ID Card', 'Passport'
  final String idNumber;
  final String documentUrl;
  String status; // 'pending', 'verified', 'rejected'
  final DateTime submittedAt;
  DateTime? reviewedAt;
  String? remarks;

  KYCSubmission({
    this.id = "",
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.isPremium = false,
    this.documents = const {},
    this.idType = "",
    this.idNumber = "",
    this.documentUrl = "",
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.remarks,
  });

  factory KYCSubmission.fromJson(Map<String, dynamic> json) {
    return KYCSubmission(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'User',
      userEmail: json['user_email'] as String? ?? '',
      isPremium: json['is_premium'] as bool? ?? false,
      documents: (json['documents'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      idType: json['id_type'] as String? ?? '',
      idNumber: json['id_number'] as String? ?? '',
      documentUrl: json['document_url'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : DateTime.now(),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      remarks: json['remarks'] as String?,
    );
  }
}
