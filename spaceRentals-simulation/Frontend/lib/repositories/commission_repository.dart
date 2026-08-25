import '../features/commissions/domain/agent_transaction.dart';

abstract class CommissionRepository {
  Future<List<AgentTransaction>> getAgentTransactions();
  Future<AgentTransaction> getTransaction(String transactionId);
  Future<List<AgentTransaction>> getAllTransactions({String? agentId, String? status});
}
