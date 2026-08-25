import '../../../shared/models/enums.dart';

class UserProfile {
  final String id;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String firstName;
  final String lastName;
  final Role role;
  final bool isActive;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
}

class TenantProfile {
  final String id;
  final String userId;
  final bool isVerifiedTenant;
  final String? referredByAgentId;

  const TenantProfile({
    required this.id,
    required this.userId,
    required this.isVerifiedTenant,
    this.referredByAgentId,
  });
}

class LandlordProfile {
  final String id;
  final String userId;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiresAt;
  final int activeListingCapacity;

  const LandlordProfile({
    required this.id,
    required this.userId,
    required this.subscriptionStatus,
    this.subscriptionExpiresAt,
    required this.activeListingCapacity,
  });
}

class AgentUserProfile {
  final String id;
  final String userId;
  final String referralCode;
  final bool isKycVerified;
  final String? kycDocumentUrl;
  final WalletStatus walletStatus;

  const AgentUserProfile({
    required this.id,
    required this.userId,
    required this.referralCode,
    required this.isKycVerified,
    this.kycDocumentUrl,
    required this.walletStatus,
  });
}
