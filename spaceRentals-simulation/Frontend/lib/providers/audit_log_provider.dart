import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuditLogEntry {
  final String id;
  final String action;
  final String actorId;
  final String actorName;
  final String targetId;
  final String targetDescription;
  final DateTime timestamp;
  final String ipAddress;
  final Map<String, dynamic> metadata;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    required this.targetId,
    required this.targetDescription,
    required this.timestamp,
    this.ipAddress = '192.168.x.x',
    this.metadata = const {},
  });

  String get formattedTimestamp {
    final d = timestamp;
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}:${d.second.toString().padLeft(2,'0')} UTC';
  }
}

class AuditLogNotifier extends Notifier<List<AuditLogEntry>> {
  @override
  List<AuditLogEntry> build() {
    return [
      AuditLogEntry(
        id: 'log_seed_1',
        action: 'USER_LOGIN',
        actorId: 'tenant_1',
        actorName: 'Alice Nguema',
        targetId: 'session_001',
        targetDescription: 'Session opened',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AuditLogEntry(
        id: 'log_seed_2',
        action: 'PAYMENT_PROCESSED',
        actorId: 'tenant_1',
        actorName: 'Alice Nguema',
        targetId: 'txn_aug_001',
        targetDescription: 'Rent payment — 150,000 CFA via MTN MoMo',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {'amount': 150000, 'method': 'MTN MoMo'},
      ),
    ];
  }

  void addLog(AuditLogEntry entry) {
    state = [entry, ...state];
  }

  void logLeaseSignature({
    required String tenantId,
    required String tenantName,
    required String propertyId,
    required String rentalId,
  }) {
    addLog(AuditLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      action: 'LEASE_SIGNED',
      actorId: tenantId,
      actorName: tenantName,
      targetId: rentalId,
      targetDescription: 'Digital Rental Agreement signed for Property $propertyId — OHADA compliant',
      timestamp: DateTime.now(),
      metadata: {
        'propertyId': propertyId,
        'rentalId': rentalId,
        'signatureHash': 'SHA256:${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
        'legalFramework': 'OHADA Uniform Act + Law No. 2010/021',
      },
    ));
  }

  void logApplicationAction({
    required String actorId,
    required String actorName,
    required String applicantName,
    required String action, // 'APPROVED' or 'REJECTED'
    required String propertyTitle,
  }) {
    addLog(AuditLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      action: 'APPLICATION_$action',
      actorId: actorId,
      actorName: actorName,
      targetId: 'app_${DateTime.now().millisecondsSinceEpoch}',
      targetDescription: '$applicantName\'s application for "$propertyTitle" was $action',
      timestamp: DateTime.now(),
    ));
  }
}

final auditLogProvider = NotifierProvider<AuditLogNotifier, List<AuditLogEntry>>(() {
  return AuditLogNotifier();
});
