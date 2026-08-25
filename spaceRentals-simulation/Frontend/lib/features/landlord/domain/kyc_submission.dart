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
}
