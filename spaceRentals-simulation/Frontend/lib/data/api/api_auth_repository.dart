import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api/api_endpoints.dart';
import '../../features/auth/domain/user_session.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../core/api/api_client.dart';
import '../../repositories/auth_repository.dart';
import '../../services/session_storage_service.dart';
import '../../shared/models/enums.dart';

/// ApiAuthRepository
///
/// Connects to the real Node.js/Express backend for authentication.
/// All successful auth calls persist the session to device storage via
/// SessionStorageService so the user stays logged in across app restarts.
class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  UserSession? _cachedSession;

  ApiAuthRepository(this._apiClient);
  Future<UserSession?> getCurrentSession() async {
    // 1. Return in-memory cache if valid
    if (_cachedSession != null && !_cachedSession!.isExpired) {
      return _cachedSession;
    }
    // 2. Try to restore from encrypted device storage
    final stored = await SessionStorageService.instance.loadSession();
    if (stored != null) {
      // Optionally: verify the token is still valid by calling /api/auth/me
      // For now we trust the stored expiry check inside loadSession()
      _cachedSession = stored;
      return _cachedSession;
    }
    return null;
  }

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.signIn),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw body['message'] ?? 'Login failed. Please check your credentials.';
    }

    final session = _sessionFromResponse(body);
    await SessionStorageService.instance.saveSession(session);
    _cachedSession = session;
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
    final name = '$firstName $lastName'.trim();
    final response = await http.post(
      Uri.parse(ApiEndpoints.signUp),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role.toLowerCase(),
      }),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw body['message'] ?? 'Registration failed. Please try again.';
    }

    final session = _sessionFromResponse(body, firstName: firstName, lastName: lastName);
    await SessionStorageService.instance.saveSession(session);
    _cachedSession = session;
    return session;
  }

  @override
  Future<void> signOut() async {
    await SessionStorageService.instance.clearSession();
    _cachedSession = null;
    // Backend logout endpoint (fire-and-forget — device-side wipe is the real log-out)
    try {
      final token = await SessionStorageService.instance.getAccessToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiEndpoints.signOut),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {}
  }

  @override
  Future<UserSession> refreshSession() async {
    // Call /api/auth/me to validate token is still alive
    final token = await SessionStorageService.instance.getAccessToken();
    if (token == null) throw Exception('No token — user must sign in again.');

    final response = await http.get(
      Uri.parse(ApiEndpoints.me),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      await SessionStorageService.instance.clearSession();
      throw Exception('Session expired — please sign in again.');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    // /me returns the user object; re-wrap with the existing token
    final nameParts = ((body['name'] ?? '') as String).split(' ');
    final refreshed = UserSession(
      userId: body['id'] ?? '',
      email: body['email'] ?? '',
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      role: _parseRole(body['role']),
      isKycVerified: body['isKycVerified'] == true || body['kycVerified'] == true,
      accessToken: token,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    await SessionStorageService.instance.updateToken(token, refreshed.expiresAt, refreshed.userId);
    _cachedSession = refreshed;
    return refreshed;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await http.post(
      Uri.parse(ApiEndpoints.passwordReset),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    final session = await getCurrentSession();
    if (session == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(ApiEndpoints.userProfile),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.statusCode != 200) throw Exception('Failed to load profile');
    final body = json.decode(response.body) as Map<String, dynamic>;

    return UserProfile(
      id: body['id'] ?? session.userId,
      email: body['email'] ?? session.email,
      firstName: body['firstName'] ?? session.firstName,
      lastName: body['lastName'] ?? session.lastName,
      phone: body['phone'],
      avatarUrl: body['avatarUrl'],
      role: _parseRole(body['role']),
      isActive: body['isActive'] ?? true,
      createdAt: DateTime.tryParse(body['createdAt'] ?? '') ?? DateTime.now(),
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
    final token = await SessionStorageService.instance.getAccessToken();
    final response = await http.patch(
      Uri.parse(ApiEndpoints.userProfile),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (twoFactorEnabled != null) 'twoFactorEnabled': twoFactorEnabled,
        if (pushNotificationsEnabled != null) 'pushNotificationsEnabled': pushNotificationsEnabled,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await SessionStorageService.instance.getAccessToken();
    final response = await http.patch(
      Uri.parse(ApiEndpoints.changePassword),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to change password');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  UserSession _sessionFromResponse(
    Map<String, dynamic> body, {
    String? firstName,
    String? lastName,
  }) {
    final token = body['token'] as String;
    final user = body['user'] as Map<String, dynamic>;
    final nameParts = ((user['name'] ?? '') as String).split(' ');

    // JWT expires in 7 days (match backend expiresIn: '7d')
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    return UserSession(
      userId: user['id'] ?? '',
      email: user['email'] ?? '',
      firstName: firstName ?? (nameParts.isNotEmpty ? nameParts.first : ''),
      lastName: lastName ?? (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''),
      role: _parseRole(user['role']),
      isKycVerified: user['isKycVerified'] == true || user['kycVerified'] == true,
      accessToken: token,
      expiresAt: expiresAt,
    );
  }

  Role _parseRole(dynamic roleStr) {
    return Role.values.firstWhere(
      (r) => r.name == (roleStr?.toString().toLowerCase() ?? 'tenant'),
      orElse: () => Role.tenant,
    );
  }
}
