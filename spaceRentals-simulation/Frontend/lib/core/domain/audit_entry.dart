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
}
