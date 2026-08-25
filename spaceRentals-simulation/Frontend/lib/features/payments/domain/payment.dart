import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class PaymentIntent {
  final String id;
  final Money amount;
  final PaymentMethod method;
  final PaymentProvider provider;
  final PaymentStatus status;
  final String? redirectUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  const PaymentIntent({
    required this.id,
    required this.amount,
    required this.method,
    required this.provider,
    required this.status,
    this.redirectUrl,
    required this.createdAt,
    required this.expiresAt,
  });
}

class Payment {
  final String id;
  final String referenceId;
  final String referenceType;
  final Money amount;
  final PaymentMethod method;
  final PaymentProvider provider;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Payment({
    required this.id,
    required this.referenceId,
    required this.referenceType,
    required this.amount,
    required this.method,
    required this.provider,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
}

class CreatePaymentRequest {
  final String referenceId;
  final String referenceType;
  final int amountUnits;
  final PaymentMethod method;
  final String phoneNumber;
  final String? idempotencyKey;

  const CreatePaymentRequest({
    required this.referenceId,
    required this.referenceType,
    required this.amountUnits,
    required this.method,
    required this.phoneNumber,
    this.idempotencyKey,
  });
}
