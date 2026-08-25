import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/domain/user_session.dart';
import '../shared/models/enums.dart';

/// SessionStorageService
///
/// Implements a two-tier storage strategy for user sessions:
///
///   1. flutter_secure_storage (encrypted)  → JWT access token
///      Stored in the device's Keystore/Keychain so it can never be
///      read by other apps even if the device is rooted.
///
///   2. SharedPreferences (local storage) → non-sensitive session data
///      userId, email, firstName, lastName, phone, avatarUrl, role,
///      expiresAt, and preferences (push, 2FA flags).
///
/// On app launch, both stores are read and a UserSession is reconstructed
/// in memory. If the token is missing or expired, null is returned so
/// the AuthNotifier routes the user to /login.
///
/// Each user's data is keyed under their userId — so multiple accounts
/// can be cached on the same device without one overwriting the other.
class SessionStorageService {
  SessionStorageService._();
  static final SessionStorageService instance = SessionStorageService._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Secure key names ──────────────────────────────────────────────────────
  static const _kToken = 'sr_access_token';
  static const _kLastUserId = 'sr_last_user_id';

  // ── SharedPreferences key prefix ──────────────────────────────────────────
  static const _kPrefix = 'sr_session_'; // e.g. sr_session_userId

  String _prefKey(String userId, String field) => '${_kPrefix}${userId}_$field';

  // ── SAVE ──────────────────────────────────────────────────────────────────

  /// Persists the full session after a successful login or sign-up.
  Future<void> saveSession(UserSession session) async {
    // 1. Store the JWT securely (encrypted)
    await _secureStorage.write(key: _kToken, value: session.accessToken);
    // 2. Store the userId that owns this token so we can look up prefs on startup
    await _secureStorage.write(key: _kLastUserId, value: session.userId);

    // 3. Store non-sensitive user data in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final uid = session.userId;
    await prefs.setString(_prefKey(uid, 'userId'), session.userId);
    await prefs.setString(_prefKey(uid, 'email'), session.email);
    await prefs.setString(_prefKey(uid, 'firstName'), session.firstName);
    await prefs.setString(_prefKey(uid, 'lastName'), session.lastName);
    await prefs.setString(_prefKey(uid, 'role'), session.role.name);
    await prefs.setString(
        _prefKey(uid, 'expiresAt'), session.expiresAt.toIso8601String());
    if (session.phone != null) {
      await prefs.setString(_prefKey(uid, 'phone'), session.phone!);
    }
    if (session.avatarUrl != null) {
      await prefs.setString(_prefKey(uid, 'avatarUrl'), session.avatarUrl!);
    }
    await prefs.setBool(
        _prefKey(uid, 'twoFactorEnabled'), session.twoFactorEnabled);
    await prefs.setBool(_prefKey(uid, 'pushNotificationsEnabled'),
        session.pushNotificationsEnabled);
  }

  // ── LOAD ──────────────────────────────────────────────────────────────────

  /// Restores the session on cold start. Returns null if nothing is stored
  /// or if the stored token is expired.
  Future<UserSession?> loadSession() async {
    try {
      // 1. Read the encrypted token
      final token = await _secureStorage.read(key: _kToken);
      if (token == null || token.isEmpty) return null;

      // 2. Read which user owns this token
      final uid = await _secureStorage.read(key: _kLastUserId);
      if (uid == null || uid.isEmpty) return null;

      // 3. Read non-sensitive data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final expiresAtStr = prefs.getString(_prefKey(uid, 'expiresAt'));
      if (expiresAtStr == null) return null;

      final expiresAt = DateTime.parse(expiresAtStr);
      if (DateTime.now().isAfter(expiresAt)) {
        // Token expired — wipe stored session so user is asked to re-login
        await clearSession();
        return null;
      }

      final roleStr =
          prefs.getString(_prefKey(uid, 'role')) ?? Role.tenant.name;
      final role = Role.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => Role.tenant,
      );

      return UserSession(
        userId: prefs.getString(_prefKey(uid, 'userId')) ?? uid,
        email: prefs.getString(_prefKey(uid, 'email')) ?? '',
        firstName: prefs.getString(_prefKey(uid, 'firstName')) ?? '',
        lastName: prefs.getString(_prefKey(uid, 'lastName')) ?? '',
        phone: prefs.getString(_prefKey(uid, 'phone')),
        avatarUrl: prefs.getString(_prefKey(uid, 'avatarUrl')),
        role: role,
        accessToken: token,
        expiresAt: expiresAt,
        twoFactorEnabled:
            prefs.getBool(_prefKey(uid, 'twoFactorEnabled')) ?? false,
        pushNotificationsEnabled:
            prefs.getBool(_prefKey(uid, 'pushNotificationsEnabled')) ?? true,
      );
    } catch (e) {
      // Corrupt storage — wipe and require fresh login
      await clearSession();
      return null;
    }
  }

  // ── UPDATE (partial) ──────────────────────────────────────────────────────

  /// Update only the profile fields after a profile-edit API call.
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    bool? twoFactorEnabled,
    bool? pushNotificationsEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (firstName != null) prefs.setString(_prefKey(userId, 'firstName'), firstName);
    if (lastName != null) prefs.setString(_prefKey(userId, 'lastName'), lastName);
    if (phone != null) prefs.setString(_prefKey(userId, 'phone'), phone);
    if (avatarUrl != null) prefs.setString(_prefKey(userId, 'avatarUrl'), avatarUrl);
    if (twoFactorEnabled != null) prefs.setBool(_prefKey(userId, 'twoFactorEnabled'), twoFactorEnabled);
    if (pushNotificationsEnabled != null) prefs.setBool(_prefKey(userId, 'pushNotificationsEnabled'), pushNotificationsEnabled);
  }

  /// Replace the stored access token (after a token refresh).
  Future<void> updateToken(String newToken, DateTime newExpiry, String userId) async {
    await _secureStorage.write(key: _kToken, value: newToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey(userId, 'expiresAt'), newExpiry.toIso8601String());
  }

  // ── CLEAR ─────────────────────────────────────────────────────────────────

  /// Wipes the session for the current user (called on sign-out).
  Future<void> clearSession() async {
    final uid = await _secureStorage.read(key: _kLastUserId);
    await _secureStorage.delete(key: _kToken);
    await _secureStorage.delete(key: _kLastUserId);

    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      // Remove all keys belonging to this user
      final keysToRemove = prefs.getKeys()
          .where((k) => k.startsWith('${_kPrefix}${uid}_'))
          .toList();
      for (final k in keysToRemove) {
        await prefs.remove(k);
      }
    }
  }

  // ── TOKEN ACCESSOR ────────────────────────────────────────────────────────

  /// Read the raw access token for use in HTTP Authorization headers.
  Future<String?> getAccessToken() => _secureStorage.read(key: _kToken);
}
