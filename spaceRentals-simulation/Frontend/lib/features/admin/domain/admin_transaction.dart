class AdminTransaction {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final int amount;
  final String currency;
  final String paymentMethod;
  final String transactionType;
  final String referenceType;
  final String referenceId;
  final String? gatewayTxId;
  final String status;
  final DateTime createdAt;

  const AdminTransaction({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionType,
    required this.referenceType,
    required this.referenceId,
    this.gatewayTxId,
    required this.status,
    required this.createdAt,
  });

  factory AdminTransaction.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic>
        ? user
        : user is Map
        ? Map<String, dynamic>.from(user)
        : <String, dynamic>{};

    return AdminTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? userMap['id']?.toString() ?? '',
      userName: userMap['name']?.toString(),
      userEmail: userMap['email']?.toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'XAF',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      referenceType: json['referenceType']?.toString() ?? '',
      referenceId: json['referenceId']?.toString() ?? '',
      gatewayTxId: json['gatewayTxId']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class AdminReportsSummary {
  final int totalUsers;
  final Map<String, int> usersByRole;
  final int totalProperties;
  final int totalApplications;
  final int totalLeases;
  final int totalRentals;
  final int totalRevenueXaf;
  final int activeSubscriptions;
  final int pendingKyc;

  const AdminReportsSummary({
    required this.totalUsers,
    required this.usersByRole,
    required this.totalProperties,
    required this.totalApplications,
    required this.totalLeases,
    required this.totalRentals,
    required this.totalRevenueXaf,
    required this.activeSubscriptions,
    required this.pendingKyc,
  });

  factory AdminReportsSummary.fromJson(Map<String, dynamic> json) {
    final users = json['users'] is Map
        ? Map<String, dynamic>.from(json['users'] as Map)
        : const <String, dynamic>{};
    final roles = <String, int>{};
    final rawRoles = users['byRole'];
    if (rawRoles is List) {
      for (final item in rawRoles) {
        if (item is! Map) continue;
        final role = item['role']?.toString() ?? '';
        final count = item['_count'];
        if (role.isNotEmpty && count is Map) {
          roles[role] = (count['id'] as num?)?.toInt() ?? 0;
        }
      }
    }

    int nestedInt(String key, String field) {
      final value = json[key];
      return value is Map ? (value[field] as num?)?.toInt() ?? 0 : 0;
    }

    return AdminReportsSummary(
      totalUsers: (users['total'] as num?)?.toInt() ?? 0,
      usersByRole: roles,
      totalProperties: nestedInt('properties', 'total'),
      totalApplications: nestedInt('applications', 'total'),
      totalLeases: nestedInt('leases', 'total'),
      totalRentals: nestedInt('rentals', 'total'),
      totalRevenueXaf: nestedInt('revenue', 'totalXAF'),
      activeSubscriptions: nestedInt('subscriptions', 'active'),
      pendingKyc: nestedInt('kyc', 'pending'),
    );
  }
}

class AdminTransactionList {
  final List<AdminTransaction> transactions;
  final int total;
  final int page;
  final int limit;

  const AdminTransactionList({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory AdminTransactionList.fromJson(Map<String, dynamic> json) {
    final rawList = json['transactions'] is List
        ? json['transactions'] as List
        : const <dynamic>[];

    return AdminTransactionList(
      transactions: rawList
          .map(
            (item) => AdminTransaction.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
    );
  }
}
