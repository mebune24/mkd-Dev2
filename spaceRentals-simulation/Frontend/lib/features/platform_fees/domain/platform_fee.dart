import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class PlatformFee {
  final String id;
  final String landlordId;
  final String leaseId;
  final String rentalId;
  final Money amount;
  final PlatformFeeStatus status;
  final DateTime dueAt;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlatformFee({
    required this.id,
    required this.landlordId,
    required this.leaseId,
    required this.rentalId,
    required this.amount,
    required this.status,
    required this.dueAt,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get requiresAction =>
      status == PlatformFeeStatus.due ||
      status == PlatformFeeStatus.overdue ||
      status == PlatformFeeStatus.failed;
}
