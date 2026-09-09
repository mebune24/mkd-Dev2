class LandlordDashboardSnapshot {
  final DateTime generatedAt;
  final int totalProperties;
  final int activeListings;
  final int rentedProperties;
  final int pendingApplications;
  final int activeRentals;
  final int occupiedProperties;
  final double occupancyRate;
  final int expectedMonthlyRent;
  final int collectedThisMonth;
  final int pendingAmount;
  final int openMaintenance;
  final int unreadMessages;
  final List<LandlordActivity> recentActivity;
  final List<RentCollectionPoint> monthlyCollections;

  const LandlordDashboardSnapshot({
    required this.generatedAt,
    required this.totalProperties,
    required this.activeListings,
    required this.rentedProperties,
    required this.pendingApplications,
    required this.activeRentals,
    required this.occupiedProperties,
    required this.occupancyRate,
    required this.expectedMonthlyRent,
    required this.collectedThisMonth,
    required this.pendingAmount,
    required this.openMaintenance,
    required this.unreadMessages,
    required this.recentActivity,
    required this.monthlyCollections,
  });

  factory LandlordDashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final properties = _map(json['properties']);
    final applications = _map(json['applications']);
    final occupancy = _map(json['occupancy']);
    final finance = _map(json['finance']);

    return LandlordDashboardSnapshot(
      generatedAt:
          DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
      totalProperties: _integer(properties['total']),
      activeListings: _integer(properties['activeListings']),
      rentedProperties: _integer(properties['rented']),
      pendingApplications: _integer(applications['pending']),
      activeRentals: _integer(json['activeRentals']),
      occupiedProperties: _integer(occupancy['occupiedProperties']),
      occupancyRate: _number(occupancy['occupancyRate']),
      expectedMonthlyRent: _integer(occupancy['expectedMonthlyRent']),
      collectedThisMonth: _integer(finance['collectedThisMonth']),
      pendingAmount: _integer(finance['pendingAmount']),
      openMaintenance: _integer(json['openMaintenance']),
      unreadMessages: _integer(json['unreadMessages']),
      recentActivity: (json['recentActivity'] is List)
          ? (json['recentActivity'] as List)
                .whereType<Map>()
                .map(
                  (item) => LandlordActivity.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      monthlyCollections: (finance['monthlyCollections'] is List)
          ? (finance['monthlyCollections'] as List)
                .whereType<Map>()
                .map(
                  (item) => RentCollectionPoint.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static int _integer(dynamic value) => value is num ? value.toInt() : 0;

  static double _number(dynamic value) => value is num ? value.toDouble() : 0;
}

class LandlordActivity {
  final String type;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  const LandlordActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory LandlordActivity.fromJson(Map<String, dynamic> json) {
    return LandlordActivity(
      type: json['type']?.toString() ?? 'activity',
      title: json['title']?.toString() ?? 'Activity',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class RentCollectionPoint {
  final String month;
  final int amount;

  const RentCollectionPoint({required this.month, required this.amount});

  factory RentCollectionPoint.fromJson(Map<String, dynamic> json) {
    return RentCollectionPoint(
      month: json['month']?.toString() ?? '',
      amount: json['amount'] is num ? (json['amount'] as num).toInt() : 0,
    );
  }
}
