import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/property_repository.dart';
import '../repositories/application_repository.dart';
import '../repositories/lease_repository.dart';

import '../data/api/api_auth_repository.dart';
import '../data/api/api_property_repository.dart';
import '../data/mock/mock_application_repository.dart';
import '../data/mock/mock_lease_repository.dart';
import '../services/session_storage_service.dart';

// ── Session Storage ────────────────────────────────────────────────────────
/// Global access to the SessionStorageService singleton.
final sessionStorageProvider = Provider<SessionStorageService>((ref) {
  return SessionStorageService.instance;
});

// ── Auth ───────────────────────────────────────────────────────────────────
/// Provides the AuthRepository implementation.
/// Uses the real API backend — falls back gracefully if the backend is offline
/// because the session is already stored on device.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});

// ── Authorization Header ───────────────────────────────────────────────────
/// Reads the stored JWT and returns an Authorization header map.
/// All API repositories should use this for authenticated requests.
final authHeaderProvider = FutureProvider<Map<String, String>>((ref) async {
  final token = await SessionStorageService.instance.getAccessToken();
  if (token == null || token.isEmpty) return {};
  return {'Authorization': 'Bearer $token'};
});

// ── Properties ─────────────────────────────────────────────────────────────
/// Provides the PropertyRepository implementation
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return ApiPropertyRepository();
});

// ── Applications ───────────────────────────────────────────────────────────
/// Provides the ApplicationRepository implementation
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return MockApplicationRepository();
});

// ── Leases ─────────────────────────────────────────────────────────────────
/// Provides the LeaseRepository implementation
final leaseRepositoryProvider = Provider<LeaseRepository>((ref) {
  return MockLeaseRepository();
});
