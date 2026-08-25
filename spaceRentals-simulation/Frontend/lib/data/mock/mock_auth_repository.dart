import 'package:uuid/uuid.dart';
import '../../features/auth/domain/user_session.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../shared/models/enums.dart';
import '../../services/session_storage_service.dart';

const _uuid = Uuid();

/// MockAuthRepository with persistent session storage.
///
/// Session is saved to device storage (encrypted JWT + SharedPreferences)
/// on every signIn/signUp and cleared on signOut. On cold-start,
/// [getCurrentSession] restores the saved session automatically.
class MockAuthRepository implements AuthRepository {
  // In-memory cache — rebuilt from storage on first call to getCurrentSession
  UserSession? _currentSession;

  @override
  Future<UserSession?> getCurrentSession() async {
    // Return in-memory session if already loaded
    if (_currentSession != null && !_currentSession!.isExpired) {
      return _currentSession;
    }
    // Otherwise try to restore from device storage
    final stored = await SessionStorageService.instance.loadSession();
    _currentSession = stored;
    return _currentSession;
  }

  @override
  Future<UserSession> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Dev convenience: role is determined by email prefix
    UserSession session;
    if (email.startsWith('admin')) {
      session = UserSession(
        userId: 'admin_1',
        email: email,
        firstName: 'System',
        lastName: 'Admin',
        role: Role.admin,
        accessToken: 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    } else if (email.startsWith('agent')) {
      session = UserSession(
        userId: 'agent_1',
        email: email,
        firstName: 'Top',
        lastName: 'Agent',
        role: Role.agent,
        accessToken: 'mock_agent_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    } else if (email.startsWith('landlord')) {
      session = UserSession(
        userId: 'landlord_1',
        email: email,
        firstName: 'Space',
        lastName: 'Landlord',
        role: Role.landlord,
        accessToken: 'mock_landlord_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    } else {
      session = UserSession(
        userId: 'tenant_1',
        email: email,
        firstName: 'Happy',
        lastName: 'Tenant',
        role: Role.tenant,
        accessToken: 'mock_tenant_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    }

    // Persist to device storage
    await SessionStorageService.instance.saveSession(session);
    _currentSession = session;
    return session;
  }

  @override
  Future<UserSession> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? referralCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final userRole = Role.values.firstWhere(
      (e) => e.name == role.toLowerCase(),
      orElse: () => Role.tenant,
    );
    final session = UserSession(
      userId: _uuid.v4(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: userRole,
      accessToken: 'mock_new_token_${_uuid.v4()}',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    // Persist to device storage
    await SessionStorageService.instance.saveSession(session);
    _currentSession = session;
    return session;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Wipe from device storage
    await SessionStorageService.instance.clearSession();
    _currentSession = null;
  }

  @override
  Future<UserSession> refreshSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentSession == null) throw Exception('No active session');

    final refreshed = UserSession(
      userId: _currentSession!.userId,
      email: _currentSession!.email,
      firstName: _currentSession!.firstName,
      lastName: _currentSession!.lastName,
      role: _currentSession!.role,
      accessToken: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    // Persist refreshed token to storage
    await SessionStorageService.instance.updateToken(
      refreshed.accessToken,
      refreshed.expiresAt,
      refreshed.userId,
    );
    _currentSession = refreshed;
    return refreshed;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // No-op in mock
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentSession == null) throw Exception('Not authenticated');
    return UserProfile(
      id: _currentSession!.userId,
      email: _currentSession!.email,
      firstName: _currentSession!.firstName,
      lastName: _currentSession!.lastName,
      role: _currentSession!.role,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    bool? twoFactorEnabled,
    bool? pushNotificationsEnabled,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op in mock
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op in mock
  }
}
