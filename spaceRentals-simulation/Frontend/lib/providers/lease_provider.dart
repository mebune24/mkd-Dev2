import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di_providers.dart';
import '../features/leases/domain/lease.dart';
import '../shared/models/enums.dart';

// --- Tenant Leases --- //

final tenantLeasesProvider = FutureProvider<List<Lease>>((ref) async {
  final repo = ref.watch(leaseRepositoryProvider);
  return repo.getTenantLeases();
});

// --- Landlord Leases --- //

final landlordLeasesProvider = FutureProvider<List<Lease>>((ref) async {
  final repo = ref.watch(leaseRepositoryProvider);
  return repo.getLandlordLeases();
});

// --- Lease Actions --- //

class LeaseSignatureNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signLease(String leaseId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(leaseRepositoryProvider);
      await repo.signLease(leaseId);
      state = const AsyncData(null);
      // Invalidate both in case role isn't strictly defined in scope
      ref.invalidate(tenantLeasesProvider);
      ref.invalidate(landlordLeasesProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final leaseSignatureProvider = NotifierProvider<LeaseSignatureNotifier, AsyncValue<void>>(LeaseSignatureNotifier.new);
