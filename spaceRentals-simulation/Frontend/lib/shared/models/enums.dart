enum Role {
  tenant,
  landlord,
  agent,
  admin,
}

enum PropertyVerificationLevel {
  unverified,
  documentsSubmitted,
  ownerVerified,
  propertyVerified,
  physicallyInspected,
}

enum PropertyAvailabilityStatus {
  available,
  confirmationDue,
  stale,
  autoUnpublished,
  rented,
}

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  withdrawn,
  expired,
}

enum LeaseStatus {
  draft,
  generated,
  pendingTenantSignature,
  pendingLandlordSignature,
  partiallySigned,
  signed,
  expired,
  cancelled,
}

enum RentalStatus {
  pendingInitialPayment,
  pendingPlatformFee,
  active,
  ended,
  cancelled,
  disputed,
}

enum PaymentStatus {
  created,
  pending,
  processing,
  successful,
  failed,
  cancelled,
  expired,
  unknown,
}

enum PlatformFeeStatus {
  pending,
  due,
  processing,
  paid,
  failed,
  overdue,
  waived,
}

enum WalletStatus {
  active,
  frozen,
  restricted,
}

enum CommissionStatus {
  pending,
  eligible,
  available,
  withdrawalRequested,
  processing,
  paid,
  failed,
  reversed,
}

enum CommissionType {
  propertyAcquisition,
  tenantReferral,
}

enum WithdrawalStatus {
  requested,
  processing,
  paid,
  failed,
  cancelled,
}

enum AgentApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  suspended,
}

enum SignatureStatus {
  pending,
  signed,
  declined,
}

enum PaymentProvider {
  campay,
  flutterwave,
  other,
}

enum PaymentMethod {
  mobileMoney,
  bank,
  card,
}

enum SubscriptionStatus {
  active,
  paymentDue,
  gracePeriod,
  expired,
  cancelled,
}
