class AuditEntry {
  final String id;
  final String userId;
  final String userRole;
  final String action;
  final String resourceId;
  final String resourceType;
  final String? actorName;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  AuditEntry({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.action,
    this.resourceId = '',
    this.resourceType = '',
    this.actorName,
    this.metadata = const {},
    required this.timestamp,
  });

  String get formattedTimestamp => timestamp.toLocal().toIso8601String();

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      userRole: json['user'] is Map
          ? json['user']['role']?.toString() ?? ''
          : json['userRole']?.toString() ?? json['user_role']?.toString() ?? '',
      action: json['action'] as String? ?? '',
      resourceId: json['resourceId']?.toString() ?? '',
      resourceType: json['resourceType']?.toString() ?? '',
      actorName: json['user'] is Map ? json['user']['name']?.toString() : null,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
      timestamp:
          DateTime.tryParse(
            (json['createdAt'] ?? json['timestamp'])?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
