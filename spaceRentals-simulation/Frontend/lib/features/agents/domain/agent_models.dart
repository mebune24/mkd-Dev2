class AgentTransaction {
  final String id;
  final String agentId;
  final double amount;
  final String type; // 'Property Verification', 'Tenant Referral', 'Mobile Withdrawal'
  String status;     // 'Pending', 'Available', 'Processing', 'Approved', 'Withdrawn', 'Reversed', 'Rejected', 'Paid'
  final String? referenceId;
  final String? sourceEvent; // e.g. 'LEASE_SIGNED', 'WITHDRAWAL_REQUESTED'
  final DateTime createdAt;
  DateTime? updatedAt;

  AgentTransaction({
    required this.id,
    required this.agentId,
    required this.amount,
    required this.type,
    required this.status,
    this.referenceId,
    this.sourceEvent,
    required this.createdAt,
    this.updatedAt,
  });

  factory AgentTransaction.fromJson(Map<String, dynamic> json) {
    return AgentTransaction(
      id: json['id'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      sourceEvent: json['sourceEvent'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class AgentProfile {
  final String userId;
  final String agentId;
  final String name;
  final String email;
  final String phone;
  final String location;
  final List<String> categories;
  final List<String> areasServed;
  final String referralCode;
  int propertiesSubmitted;
  int propertiesVerified;
  int propertiesRejected;
  int tenantsReferred;
  int qualifiedTenants;
  int landlordRelationships;
  int pendingLandlordRequests;
  double rating;
  bool isWalletFrozen;
  String status; // 'active', 'pending', 'suspended'

  AgentProfile({
    required this.userId,
    this.agentId = '',
    required this.name,
    this.email = '',
    this.phone = '',
    this.location = '',
    this.categories = const [],
    this.areasServed = const [],
    this.referralCode = '',
    this.propertiesSubmitted = 0,
    this.propertiesVerified = 0,
    this.propertiesRejected = 0,
    this.tenantsReferred = 0,
    this.qualifiedTenants = 0,
    this.landlordRelationships = 0,
    this.pendingLandlordRequests = 0,
    this.rating = 0.0,
    this.isWalletFrozen = false,
    required this.status,
  });

  factory AgentProfile.fromJson(Map<String, dynamic> json) {
    return AgentProfile(
      userId: json['userId'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      areasServed: (json['areasServed'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      referralCode: json['referralCode'] as String? ?? '',
      propertiesSubmitted: json['propertiesSubmitted'] as int? ?? 0,
      propertiesVerified: json['propertiesVerified'] as int? ?? 0,
      propertiesRejected: json['propertiesRejected'] as int? ?? 0,
      tenantsReferred: json['tenantsReferred'] as int? ?? 0,
      qualifiedTenants: json['qualifiedTenants'] as int? ?? 0,
      landlordRelationships: json['landlordRelationships'] as int? ?? 0,
      pendingLandlordRequests: json['pendingLandlordRequests'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isWalletFrozen: json['isWalletFrozen'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );
  }
}

class AgentServiceAgreement {
  final String id;
  final String landlordId;
  final String landlordName;
  final String agentId;
  final String agentName;
  String status; // 'Pending', 'Accepted', 'Active', 'Suspended', 'Terminated'
  final DateTime requestedAt;
  DateTime? acceptedAt;
  final String serviceTerms;

  AgentServiceAgreement({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.agentId,
    required this.agentName,
    required this.status,
    required this.requestedAt,
    this.acceptedAt,
    required this.serviceTerms,
  });

  factory AgentServiceAgreement.fromJson(Map<String, dynamic> json) {
    return AgentServiceAgreement(
      id: json['id'] as String? ?? '',
      landlordId: json['landlordId'] as String? ?? '',
      landlordName: json['landlordName'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      agentName: json['agentName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      serviceTerms: json['serviceTerms'] as String? ?? '',
    );
  }
}
