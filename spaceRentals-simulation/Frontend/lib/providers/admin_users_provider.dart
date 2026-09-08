import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/api/api_endpoints.dart';
import 'di_providers.dart';

class AdminUserProfile {
  final String id;
  final String name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
  final String role;
  final String status;
  final bool twoFactorEnabled;
  final bool pushNotificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    required this.role,
    required this.status,
    required this.twoFactorEnabled,
    required this.pushNotificationsEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUserProfile.fromJson(Map<String, dynamic> json) =>
      AdminUserProfile(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        phone: json['phone']?.toString(),
        bio: json['bio']?.toString(),
        role: json['role']?.toString() ?? '',
        status: json['status']?.toString() ?? 'unknown',
        twoFactorEnabled: json['twoFactorEnabled'] == true,
        pushNotificationsEnabled: json['pushNotificationsEnabled'] != false,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );
}

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/api/admin/users');

  if (response.statusCode == 200) {
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : const <dynamic>[];
    return data.map((json) => UserModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
});

final adminUserProfileProvider =
    FutureProvider.family<AdminUserProfile, String>((ref, userId) async {
      final response = await ref
          .read(apiClientProvider)
          .get<Map<String, dynamic>>(ApiEndpoints.userById(userId));
      if (!response.isSuccess || response.data == null) {
        throw Exception(
          response.error?.message ?? 'Failed to load user profile',
        );
      }
      return AdminUserProfile.fromJson(response.data!);
    });
