enum RnlpStatus { eligible, active, completed, rejected }

class RnlpInstalment {
  final String id;
  final int month;
  final double amount;
  final bool paid;
  final DateTime dueDate;
  final String status;

  RnlpInstalment({
    required this.id,
    required this.month,
    required this.amount,
    required this.paid,
    required this.dueDate,
    required this.status,
  });
}

class RnlpModel {
  final String id;
  final String tenantId;
  final String rentalId;
  final double financedAmount;
  final double remainingBalance;
  final int totalMonths;
  final double monthlyInstalment;
  final RnlpStatus status;
  final List<RnlpInstalment> schedule;

  RnlpModel({
    required this.id,
    required this.tenantId,
    required this.rentalId,
    required this.financedAmount,
    required this.remainingBalance,
    required this.totalMonths,
    required this.monthlyInstalment,
    required this.status,
    required this.schedule,
  });

  factory RnlpModel.fromJson(Map<String, dynamic> json) {
    final rawInstalments = json['instalments'] is List
        ? json['instalments'] as List
        : const <dynamic>[];
    return RnlpModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      rentalId: json['rentalId']?.toString() ?? '',
      financedAmount: (json['financedAmount'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,
      totalMonths: (json['totalMonths'] as num?)?.toInt() ?? 0,
      monthlyInstalment: (json['monthlyInstalment'] as num?)?.toDouble() ?? 0,
      status: switch (json['status']?.toString()) {
        'completed' => RnlpStatus.completed,
        'rejected' => RnlpStatus.rejected,
        _ => RnlpStatus.active,
      },
      schedule: rawInstalments.map((item) {
        final data = Map<String, dynamic>.from(item as Map);
        final status = data['status']?.toString() ?? 'due';
        return RnlpInstalment(
          id: data['id']?.toString() ?? '',
          month: (data['installmentNumber'] as num?)?.toInt() ?? 0,
          amount: (data['amount'] as num?)?.toDouble() ?? 0,
          paid: status == 'paid',
          dueDate:
              DateTime.tryParse(data['dueDate']?.toString() ?? '') ??
              DateTime.now(),
          status: status,
        );
      }).toList(),
    );
  }
}
