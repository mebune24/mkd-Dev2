import '../../../shared/models/enums.dart';

class UserSession {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final bool twoFactorEnabled;
  final bool pushNotificationsEnabled;
  final Role role;
  final bool isKycVerified;
  final String accessToken;
  final DateTime expiresAt;

  const UserSession({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    this.twoFactorEnabled = false,
    this.pushNotificationsEnabled = true,
    required this.role,
    this.isKycVerified = false,
    required this.accessToken,
    required this.expiresAt,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  UserSession copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    bool? twoFactorEnabled,
    bool? pushNotificationsEnabled,
    bool? isKycVerified,
  }) {
    return UserSession(
      userId: userId,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      role: role,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
  }
}
