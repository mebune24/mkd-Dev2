class TenantWallet {
  final String referralCode;
  final int balance;
  final List<TenantWalletEntry> entries;

  const TenantWallet({required this.referralCode, required this.balance, required this.entries});

  factory TenantWallet.fromJson(Map<String, dynamic> json) => TenantWallet(
    referralCode: json['referralCode']?.toString() ?? '',
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    entries: (json['entries'] is List ? json['entries'] as List : const [])
        .whereType<Map>()
        .map((entry) => TenantWalletEntry.fromJson(Map<String, dynamic>.from(entry)))
        .toList(),
  );
}

class TenantWalletEntry {
  final String type;
  final int amount;
  final String description;
  final DateTime createdAt;

  const TenantWalletEntry({required this.type, required this.amount, required this.description, required this.createdAt});

  factory TenantWalletEntry.fromJson(Map<String, dynamic> json) => TenantWalletEntry(
    type: json['type']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    description: json['description']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
