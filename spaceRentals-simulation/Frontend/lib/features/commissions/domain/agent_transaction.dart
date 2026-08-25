import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class AgentTransaction {
  final String id;
  final String agentId;
  final CommissionType type;
  final Money amount;
  final CommissionStatus status;
  final String sourceEvent;
  final String referenceType;
  final String referenceId;
  final DateTime createdAt;
  final DateTime? eligibleAt;
  final DateTime? availableAt;
  final DateTime? paidAt;

  const AgentTransaction({
    required this.id,
    required this.agentId,
    required this.type,
    required this.amount,
    required this.status,
    required this.sourceEvent,
    required this.referenceType,
    required this.referenceId,
    required this.createdAt,
    this.eligibleAt,
    this.availableAt,
    this.paidAt,
  });

  String get typeLabel {
    switch (type) {
      case CommissionType.propertyAcquisition: return 'Property Acquisition';
      case CommissionType.tenantReferral: return 'Tenant Referral';
    }
  }

  String get statusLabel {
    switch (status) {
      case CommissionStatus.pending: return 'Pending';
      case CommissionStatus.eligible: return 'Eligible';
      case CommissionStatus.available: return 'Available';
      case CommissionStatus.withdrawalRequested: return 'Withdrawal Requested';
      case CommissionStatus.processing: return 'Processing';
      case CommissionStatus.paid: return 'Paid';
      case CommissionStatus.failed: return 'Failed';
      case CommissionStatus.reversed: return 'Reversed';
    }
  }
}
