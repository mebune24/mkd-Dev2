import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/api/http_api_client.dart';

import '../repositories/auth_repository.dart';
import '../repositories/property_repository.dart';
import '../repositories/application_repository.dart';
import '../repositories/lease_repository.dart';

import '../data/api/api_auth_repository.dart';
import '../data/api/api_property_repository.dart';
import '../data/api/api_application_repository.dart';
import '../data/api/api_lease_repository.dart';
import '../data/api/api_payment_repository.dart';
import '../data/api/api_agent_repository.dart';
import '../data/api/api_dispute_repository.dart';
import '../data/api/api_notification_repository.dart';
import '../data/api/api_audit_repository.dart';
import '../services/session_storage_service.dart';

// ── Session Storage ────────────────────────────────────────────────────────
/// Global access to the SessionStorageService singleton.
final sessionStorageProvider = Provider<SessionStorageService>((ref) {
  return SessionStorageService.instance;
});

// ── Api Client ─────────────────────────────────────────────────────────────
/// Central HTTP client with automatic auth header injection and
/// global 401/403 handling.
final apiClientProvider = Provider<ApiClient>((ref) {
  return HttpApiClient();
});

// ── Auth ───────────────────────────────────────────────────────────────────
/// Provides the AuthRepository implementation backed by the live Node.js API.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAuthRepository(apiClient);
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
/// Provides the PropertyRepository implementation — backed by real API.
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiPropertyRepository(apiClient);
});

// ── Applications ───────────────────────────────────────────────────────────
/// Provides the ApplicationRepository — REAL API (replaces MockApplicationRepository).
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiApplicationRepository(apiClient);
});

// ── Leases ─────────────────────────────────────────────────────────────────
/// Provides the LeaseRepository — REAL API with SHA-256 e-signature hashing.
final leaseRepositoryProvider = Provider<LeaseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiLeaseRepository(apiClient);
});

// ── Payments ───────────────────────────────────────────────────────────────
final paymentRepositoryProvider = Provider<ApiPaymentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiPaymentRepository(apiClient);
});

// ── Agents ─────────────────────────────────────────────────────────────────
final agentRepositoryProvider = Provider<ApiAgentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAgentRepository(apiClient);
});

// ── Disputes ───────────────────────────────────────────────────────────────
final disputeRepositoryProvider = Provider<ApiDisputeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiDisputeRepository(apiClient);
});

// ── Notifications ──────────────────────────────────────────────────────────
final notificationRepositoryProvider = Provider<ApiNotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiNotificationRepository(apiClient);
});

// ── Audit Logs ─────────────────────────────────────────────────────────────
final auditRepositoryProvider = Provider<ApiAuditRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAuditRepository(apiClient);
});
