import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di_providers.dart';
import '../features/applications/domain/application.dart';
import '../shared/models/enums.dart';

// --- Tenant Applications --- //

final tenantApplicationsProvider = FutureProvider<List<Application>>((ref) async {
  final repo = ref.watch(applicationRepositoryProvider);
  return repo.getTenantApplications();
});

class ApplicationSubmitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submitApplication(SubmitApplicationRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(applicationRepositoryProvider);
      await repo.submitApplication(request);
      state = const AsyncData(null);
      ref.invalidate(tenantApplicationsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> withdrawApplication(String applicationId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(applicationRepositoryProvider);
      await repo.withdrawApplication(applicationId);
      state = const AsyncData(null);
      ref.invalidate(tenantApplicationsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final applicationSubmitProvider = NotifierProvider<ApplicationSubmitNotifier, AsyncValue<void>>(ApplicationSubmitNotifier.new);


// --- Landlord Applications --- //

final landlordApplicationsProvider = FutureProvider<List<Application>>((ref) async {
  final repo = ref.watch(applicationRepositoryProvider);
  return repo.getLandlordApplications();
});

class ApplicationReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> approveApplication(String applicationId, {String? note}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(applicationRepositoryProvider);
      await repo.approveApplication(applicationId, note: note);
      state = const AsyncData(null);
      ref.invalidate(landlordApplicationsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> rejectApplication(String applicationId, {String? note}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(applicationRepositoryProvider);
      await repo.rejectApplication(applicationId, note: note);
      state = const AsyncData(null);
      ref.invalidate(landlordApplicationsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final applicationReviewProvider = NotifierProvider<ApplicationReviewNotifier, AsyncValue<void>>(ApplicationReviewNotifier.new);
