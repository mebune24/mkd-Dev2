class AgentServiceAgreement {
  final String id;
  final String landlordId;
  final String agentId;
  final String status; // Pending, Accepted, Active, Suspended, Terminated
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> serviceTerms;

  AgentServiceAgreement({
    required this.id,
    required this.landlordId,
    required this.agentId,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.serviceTerms,
  });

  AgentServiceAgreement copyWith({
    String? id,
    String? landlordId,
    String? agentId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? serviceTerms,
  }) {
    return AgentServiceAgreement(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      serviceTerms: serviceTerms ?? this.serviceTerms,
    );
  }
}
