import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class Rental {
  final String id;
  final String leaseId;
  final String propertyId;
  final String propertyTitle;
  final String tenantId;
  final String landlordId;
  final RentalStatus status;
  final Money monthlyRent;
  final DateTime? activatedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Rental({
    required this.id,
    required this.leaseId,
    required this.propertyId,
    required this.propertyTitle,
    required this.tenantId,
    required this.landlordId,
    required this.status,
    required this.monthlyRent,
    this.activatedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
