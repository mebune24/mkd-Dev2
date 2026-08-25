import '../features/auth/domain/user_session.dart';
import '../features/auth/domain/user_profile.dart';

abstract class AuthRepository {
  Future<UserSession?> getCurrentSession();
  Future<UserSession> signIn({required String email, required String password});
  Future<UserSession> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? referralCode,
  });
  Future<void> signOut();
  Future<UserSession> refreshSession();
  Future<void> requestPasswordReset({required String email});
  Future<UserProfile> getCurrentUserProfile();
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    bool? twoFactorEnabled,
    bool? pushNotificationsEnabled,
  });
  Future<void> changePassword(String currentPassword, String newPassword);
}
