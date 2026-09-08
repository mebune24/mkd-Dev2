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
