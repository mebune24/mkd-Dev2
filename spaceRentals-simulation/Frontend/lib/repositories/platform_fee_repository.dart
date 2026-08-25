import '../features/platform_fees/domain/platform_fee.dart';
import '../features/payments/domain/payment.dart';

abstract class PlatformFeeRepository {
  Future<PlatformFee> getPlatformFee(String feeId);
  Future<PlatformFee> getFeeByRentalId(String rentalId);
  Future<List<PlatformFee>> getLandlordFees();
  Future<List<PlatformFee>> getAllFees({String? status});
  Future<PaymentIntent> initiatePayment(String feeId, CreatePaymentRequest request);
  Future<PlatformFee> waiveFee(String feeId);
}
