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
}
