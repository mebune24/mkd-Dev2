class DisputeRecord {
  final String id;
  final String tenantId;
  final String landlordId;
  final String propertyId;
  final String subject;
  final String filedByName;
  final String description;
  String status; // 'open', 'under_review', 'resolved', 'closed'
  final DateTime filedAt;
  String? resolution;

  DisputeRecord({
    required this.id,
    required this.tenantId,
    required this.landlordId,
    required this.propertyId,
    required this.subject,
    required this.filedByName,
    required this.description,
    required this.status,
    required this.filedAt,
    this.resolution,
  });
}
