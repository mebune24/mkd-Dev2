import 'package:uuid/uuid.dart';
import '../../features/auth/domain/user_session.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../shared/models/enums.dart';

const _uuid = Uuid();

class MockAuthRepository implements AuthRepository {
  // No session on cold start — user must sign in or continue as guest
  UserSession? _currentSession;

  @override
  Future<UserSession?> getCurrentSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentSession;
  }

  @override
  Future<UserSession> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    // Dev convenience: role is determined by email prefix
    if (email.startsWith('admin')) {
      _currentSession = UserSession(
        userId: 'admin_1', email: email, firstName: 'System', lastName: 'Admin',
        role: Role.admin, accessToken: 'mock_admin_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    } else if (email.startsWith('agent')) {
      _currentSession = UserSession(
        userId: 'agent_1', email: email, firstName: 'Top', lastName: 'Agent',
        role: Role.agent, accessToken: 'mock_agent_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    } else if (email.startsWith('landlord')) {
      _currentSession = UserSession(
        userId: 'landlord_1', email: email, firstName: 'Space', lastName: 'Landlord',
        role: Role.landlord, accessToken: 'mock_landlord_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    } else {
      _currentSession = UserSession(
        userId: 'tenant_1', email: email, firstName: 'Happy', lastName: 'Tenant',
        role: Role.tenant, accessToken: 'mock_tenant_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    }
    return _currentSession!;
  }

  @override
  Future<UserSession> signUp({
    required String email, required String password, required String firstName,
    required String lastName, required String role, String? referralCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final userRole = Role.values.firstWhere((e) => e.name == role.toLowerCase(), orElse: () => Role.tenant);
    _currentSession = UserSession(
      userId: _uuid.v4(), email: email, firstName: firstName, lastName: lastName,
      role: userRole, accessToken: 'mock_new_token', expiresAt: DateTime.now().add(const Duration(days: 1)),
    );
    return _currentSession!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentSession = null;
  }

  @override
  Future<UserSession> refreshSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentSession == null) throw Exception('No active session');
    _currentSession = UserSession(
      userId: _currentSession!.userId, email: _currentSession!.email,
      firstName: _currentSession!.firstName, lastName: _currentSession!.lastName,
      role: _currentSession!.role, accessToken: 'refreshed_token',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    return _currentSession!;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 800));
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
}
