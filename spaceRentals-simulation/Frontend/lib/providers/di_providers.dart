import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/property_repository.dart';
import '../repositories/application_repository.dart';
import '../repositories/lease_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/platform_fee_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/commission_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/agent_repository.dart';

import '../data/mock/mock_auth_repository.dart';
import '../data/api/api_property_repository.dart';
import '../data/mock/mock_application_repository.dart';
import '../data/mock/mock_lease_repository.dart';
// Note: Some mock repos are skipped for brevity, but the DI structure is defined here.

/// Provides the AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // Swap with ApiAuthRepository later
});

/// Provides the PropertyRepository implementation
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return ApiPropertyRepository();
});

/// Provides the ApplicationRepository implementation
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return MockApplicationRepository();
});

/// Provides the LeaseRepository implementation
final leaseRepositoryProvider = Provider<LeaseRepository>((ref) {
  return MockLeaseRepository();
});
