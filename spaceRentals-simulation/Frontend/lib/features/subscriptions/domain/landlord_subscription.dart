import '../../../shared/models/enums.dart';
import '../../../core/utils/money.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final Money price;
  final int listingLimit;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.listingLimit,
    required this.features,
  });
}

class LandlordSubscription {
  final String id;
  final String landlordId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final int activeListingCount;
  final DateTime startedAt;
  final DateTime expiresAt;
  final DateTime? cancelledAt;

  const LandlordSubscription({
    required this.id,
    required this.landlordId,
    required this.plan,
    required this.status,
    required this.activeListingCount,
    required this.startedAt,
    required this.expiresAt,
    this.cancelledAt,
  });

  int get remainingSlots => plan.listingLimit - activeListingCount;
  bool get hasAvailableSlots => remainingSlots > 0;
  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.gracePeriod;

  // IMPORTANT: Subscription expiry does NOT affect existing active leases.
  // It only pauses marketplace listing access.
}
