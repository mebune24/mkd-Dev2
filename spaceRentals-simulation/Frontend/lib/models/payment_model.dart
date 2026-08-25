class PaymentModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String landlordId;
  final String tenantId;
  final String tenantName;
  final double amount;
  final String month; // e.g. "August 2026"
  final String status; // 'pending', 'approved', 'rejected'
  final String type; // 'rent', 'deposit', 'maintenance', 'other'
  final String description;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.landlordId,
    required this.tenantId,
    required this.tenantName,
    required this.amount,
    required this.month,
    required this.status,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  PaymentModel copyWith({String? status}) {
    return PaymentModel(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      landlordId: landlordId,
      tenantId: tenantId,
      tenantName: tenantName,
      amount: amount,
      month: month,
      status: status ?? this.status,
      type: type,
      description: description,
      createdAt: createdAt,
    );
  }
}
