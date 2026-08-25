enum AgreementStatus { pending, active, concluded }

class RentalModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final double rent;
  final double deposit;
  final AgreementStatus status;
  final bool tenantConfirmed;
  final bool landlordConfirmed;

  RentalModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.rent,
    required this.deposit,
    required this.status,
    required this.tenantConfirmed,
    required this.landlordConfirmed,
  });
}
