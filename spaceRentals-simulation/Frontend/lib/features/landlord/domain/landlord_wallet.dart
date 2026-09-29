class LandlordWallet {
  final String id;
  final double balance;
  final double pendingBalance;
  final List<LandlordWalletEntry> entries;

  LandlordWallet({
    required this.id,
    required this.balance,
    required this.pendingBalance,
    required this.entries,
  });

  factory LandlordWallet.fromJson(Map<String, dynamic> json) {
    return LandlordWallet(
      id: json['id'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => LandlordWalletEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LandlordWalletEntry {
  final String id;
  final String type; // rent_credit, withdrawal, platform_fee_deduction
  final double amount;
  final String description;
  final DateTime createdAt;

  LandlordWalletEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory LandlordWalletEntry.fromJson(Map<String, dynamic> json) {
    return LandlordWalletEntry(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
