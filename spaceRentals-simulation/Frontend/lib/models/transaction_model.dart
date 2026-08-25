class TransactionModel {
  final String id;
  final String userId; // Usually an Agent
  final double amount;
  final String type; // 'Property Verification', 'Tenant Referral', 'Mobile Withdrawal'
  final String status; // 'Pending', 'Approved', 'Paid', 'Rejected'
  final String? referenceId; // Property ID or Tenant ID that generated this commission
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentTransactionId; // The ID from MTN MoMo / Orange Money once Paid

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.referenceId,
    required this.createdAt,
    this.updatedAt,
    this.paymentTransactionId,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? status,
    String? referenceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentTransactionId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
    );
  }
}
