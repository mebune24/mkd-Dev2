enum RnlpStatus { eligible, active, completed, rejected }

class RnlpInstalment {
  final int month;
  final double amount;
  final bool paid;
  final DateTime dueDate;

  RnlpInstalment({
    required this.month,
    required this.amount,
    required this.paid,
    required this.dueDate,
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
}
