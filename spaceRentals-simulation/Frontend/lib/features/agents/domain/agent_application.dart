import '../../../shared/models/enums.dart';

class AgentKycApplication {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final AgentApplicationStatus status;
  final String? nationalIdUrl;
  final String? selfieUrl;
  final String? businessDocUrl;
  final String? adminNote;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const AgentKycApplication({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    this.nationalIdUrl,
    this.selfieUrl,
    this.businessDocUrl,
    this.adminNote,
    required this.submittedAt,
    required this.updatedAt,
  });
}
