import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/domain/user_profile.dart';
import '../features/auth/domain/user_session.dart';
import '../services/session_storage_service.dart';
import 'di_providers.dart';

/// State class to hold the authenticated session.
class AuthState {
  final UserSession? session;
  final bool isLoading;
  final String? error;
  final bool isGuest;
  final bool hasAcceptedTerms;

  const AuthState({
    this.session,
    this.isLoading = false,
    this.error,
    this.isGuest = false,
    this.hasAcceptedTerms = false,
  });

  /// True for real authenticated users (not guests).
  bool get isAuthenticated => session != null && !session!.isExpired;

  /// True if the user has been granted browse-only guest access.
  bool get hasAccess => isAuthenticated || isGuest;

  bool get hasConsent => hasAcceptedTerms || (session?.termsAccepted ?? false);

  AuthState copyWith({
    UserSession? session,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isGuest,
    bool? hasAcceptedTerms,
  }) {
    return AuthState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isGuest: isGuest ?? this.isGuest,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(isLoading: true);
  }

  /// On cold start: restore session from device storage (encrypted).
  Future<void> _init() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.getCurrentSession();
      final hasAcceptedTerms = await SessionStorageService.instance
          .hasAcceptedTerms();
      state = AuthState(
        session: session,
        isLoading: false,
        hasAcceptedTerms: hasAcceptedTerms,
      );
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.signIn(email: email, password: password);
      final hasAcceptedTerms = await SessionStorageService.instance
          .hasAcceptedTerms();
      state = AuthState(
        session: session,
        isLoading: false,
        hasAcceptedTerms: hasAcceptedTerms,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      final hasAcceptedTerms = await SessionStorageService.instance
          .hasAcceptedTerms();
      state = AuthState(
        session: session,
        isLoading: false,
        hasAcceptedTerms: hasAcceptedTerms,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Allows unauthenticated users to browse the app as a read-only guest.
  void continueAsGuest() {
    state = const AuthState(isGuest: true, isLoading: false);
  }

  Future<void> signOut() async {
    // Clear guest state
    if (state.isGuest) {
      state = const AuthState();
      return;
    }
    final hasAcceptedTerms = await SessionStorageService.instance
        .hasAcceptedTerms();
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = AuthState(hasAcceptedTerms: hasAcceptedTerms);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update in-memory session and persist profile changes to local storage.
  Future<void> updateSessionProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    bool? twoFactorEnabled,
    bool? pushNotificationsEnabled,
  }) async {
    final current = state.session;
    if (current == null) return;

    // Update device storage
    await SessionStorageService.instance.updateProfile(
      userId: current.userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      twoFactorEnabled: twoFactorEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled,
    );

    // Update in-memory state
    state = state.copyWith(
      session: current.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
        twoFactorEnabled: twoFactorEnabled,
        pushNotificationsEnabled: pushNotificationsEnabled,
      ),
    );
  }

  /// Keeps the locally cached verification state aligned with the server.
  Future<void> updateSessionKycStatus({
    required bool isVerified,
    String? kycStatus,
  }) async {
    final current = state.session;
    if (current == null) return;
    final updated = current.copyWith(
      isKycVerified: isVerified,
      kycStatus: kycStatus,
    );
    await SessionStorageService.instance.saveSession(updated);
    state = state.copyWith(session: updated);
  }

  void markTermsAcceptedLocally() {
    state = state.copyWith(hasAcceptedTerms: true);
  }

  void markTermsAccepted() {
    final current = state.session;
    if (current == null) {
      markTermsAcceptedLocally();
      return;
    }
    state = state.copyWith(
      session: current.copyWith(termsAccepted: true),
      hasAcceptedTerms: true,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final session = ref.watch(authProvider).session;
  if (session == null) {
    throw Exception('No authenticated user session');
  }
  return repo.getCurrentUserProfile();
});
