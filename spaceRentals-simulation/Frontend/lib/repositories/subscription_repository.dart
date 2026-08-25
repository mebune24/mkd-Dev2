import '../features/subscriptions/domain/landlord_subscription.dart';
import '../features/payments/domain/payment.dart';

abstract class SubscriptionRepository {
  Future<LandlordSubscription?> getCurrentSubscription();
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<PaymentIntent> initiateSubscription(String planId, CreatePaymentRequest request);
  Future<LandlordSubscription> getSubscriptionStatus();
}
