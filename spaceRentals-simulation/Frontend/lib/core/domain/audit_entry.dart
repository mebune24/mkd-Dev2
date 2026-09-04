class AuditEntry {
  final String id;
  final String userId;
  final String userRole;
  final String action;
  final DateTime timestamp;

  AuditEntry({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.action,
    required this.timestamp,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userRole: json['user_role'] as String? ?? '',
      action: json['action'] as String? ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
    );
  }
}
