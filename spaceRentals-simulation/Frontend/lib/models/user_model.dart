// Role enum lives in shared/models/enums.dart — DO NOT redefine here.
import 'package:space_rentals/shared/models/enums.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String status;
  final String kycStatus; // 'unverified', 'pending', 'verified', 'premium', 'agent_pending', 'agent_approved'

  // Agent Specific Fields
  final String? agentId;
  final String? referralCode;
  final String? referredByAgentId;
  final double walletBalance;
  final double pendingBalance;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.kycStatus = 'unverified',
    this.agentId,
    this.referralCode,
    this.referredByAgentId,
    this.walletBalance = 0.0,
    this.pendingBalance = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: Role.values.firstWhere((e) => e.name == json['role']),
      status: json['status'],
      kycStatus: json['kycStatus'] ?? 'unverified',
      agentId: json['agentId'],
      referralCode: json['referralCode'],
      referredByAgentId: json['referredByAgentId'],
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'status': status,
      'kycStatus': kycStatus,
      'agentId': agentId,
      'referralCode': referralCode,
      'referredByAgentId': referredByAgentId,
      'walletBalance': walletBalance,
      'pendingBalance': pendingBalance,
    };
  }
}

