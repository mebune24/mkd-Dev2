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

  factory DisputeRecord.fromJson(Map<String, dynamic> json) {
    return DisputeRecord(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      landlordId: json['landlord_id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      filedByName: json['filed_by_name'] as String? ?? 'User',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      filedAt: json['filed_at'] != null ? DateTime.parse(json['filed_at'] as String) : DateTime.now(),
      resolution: json['resolution'] as String?,
    );
  }
}
