import '../../../shared/models/enums.dart';

class UserSession {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final Role role;
  final String accessToken;
  final DateTime expiresAt;

  const UserSession({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.accessToken,
    required this.expiresAt,
  });

  String get fullName => '$firstName $lastName';
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
