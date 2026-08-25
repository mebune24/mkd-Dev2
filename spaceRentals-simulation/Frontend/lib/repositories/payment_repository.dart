import '../features/payments/domain/payment.dart';

abstract class PaymentRepository {
  Future<PaymentIntent> createPayment(CreatePaymentRequest request);
  Future<Payment> getPayment(String paymentId);
  Future<PaymentIntent> getPaymentStatus(String paymentId);
  Future<void> cancelPayment(String paymentId);
}
