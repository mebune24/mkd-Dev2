import 'package:flutter/foundation.dart';

enum Currency { xaf }

@immutable
class Money {
  final int minorUnits; // In XAF: no decimal subunit
  final Currency currency;

  const Money(this.minorUnits, {this.currency = Currency.xaf});
  static const Money zero = Money(0);

  Money operator +(Money other) {
    assert(currency == other.currency);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  bool operator >(Money other) => minorUnits > other.minorUnits;
  bool operator <(Money other) => minorUnits < other.minorUnits;
  bool operator >=(Money other) => minorUnits >= other.minorUnits;

  String formatted() {
    final str = minorUnits.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₣$str FCFA';
  }

  @override
  bool operator ==(Object other) =>
      other is Money && minorUnits == other.minorUnits && currency == other.currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => formatted();
}

/// Canonical source of truth for all Space Rentals platform fees.
///
/// These values drive both UI display and business-rule enforcement.
/// Do NOT hardcode fee amounts anywhere else in the codebase.
abstract final class SpaceFees {
  // ── Revenue streams ──────────────────────────────────────────────────────────

  /// Monthly subscription paid by the landlord for platform access.
  static const Money landlordSubscription = Money(5000);

  /// One-time fee paid by a tenant when submitting a rental application.
  static const Money tenantApplicationFee = Money(3000);

  /// Success fee charged to the landlord when a rental is confirmed
  /// (i.e. the tenant's first rent payment clears).
  static const Money rentalSuccessFee = Money(10000);

  // ── Agent commissions (Space pays out) ───────────────────────────────────────

  /// Commission paid to an agent who submitted a property that subsequently
  /// generates a confirmed rental. Triggered by PAYMENT_CONFIRMED event on
  /// the property's first successful rental.
  static const Money agentPropertyAcquisitionCommission = Money(2000);

  /// Commission paid to an agent who referred the tenant.
  /// Triggered by PAYMENT_CONFIRMED after the lease is signed.
  static const Money agentTenantReferralCommission = Money(1000);

  // ── Payment processing cost (illustrative) ───────────────────────────────────

  /// Illustrative Flutterwave collection rate for Cameroon mobile money (2%).
  /// Used in contribution-margin calculations; actual rate varies by provider.
  static const double paymentProcessingRate = 0.02;

  // ── Derived calculations ─────────────────────────────────────────────────────

  /// Gross platform revenue for a fully successful rental transaction.
  /// = subscription + application fee + success fee
  static Money grossRevenuePerRental({bool includeSubscription = true}) {
    return (includeSubscription ? landlordSubscription : Money.zero)
        + tenantApplicationFee
        + rentalSuccessFee;
  }

  /// Estimated processing cost on the success fee collection.
  static int processingCostOnSuccessFee() =>
      (rentalSuccessFee.minorUnits * paymentProcessingRate).round();

  /// Approximate contribution after agent commissions and processing costs.
  static int contributionPerRental({bool includeSubscription = true}) {
    final gross = grossRevenuePerRental(includeSubscription: includeSubscription).minorUnits;
    final agentCosts = agentPropertyAcquisitionCommission.minorUnits
        + agentTenantReferralCommission.minorUnits;
    final processing = processingCostOnSuccessFee();
    return gross - agentCosts - processing;
  }
}
