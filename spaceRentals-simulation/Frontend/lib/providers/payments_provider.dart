import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';

// ── Seed data ─────────────────────────────────────────────────────────────────
final List<PaymentModel> _seedPayments = [
  PaymentModel(
    id: 'pay_001',
    propertyId: 'prop_001',
    propertyTitle: 'Modern 2 Bedroom Apartment',
    landlordId: 'landlord_001',
    tenantId: 'tenant_001',
    tenantName: 'Alice Johnson',
    amount: 150000,
    month: 'August 2026',
    status: 'pending',
    type: 'rent',
    description: 'Monthly rent payment for August 2026',
    createdAt: DateTime(2026, 8, 1),
  ),
  PaymentModel(
    id: 'pay_002',
    propertyId: 'prop_001',
    propertyTitle: 'Modern 2 Bedroom Apartment',
    landlordId: 'landlord_001',
    tenantId: 'tenant_001',
    tenantName: 'Alice Johnson',
    amount: 150000,
    month: 'July 2026',
    status: 'approved',
    type: 'rent',
    description: 'Monthly rent payment for July 2026',
    createdAt: DateTime(2026, 7, 1),
  ),
  PaymentModel(
    id: 'pay_003',
    propertyId: 'prop_002',
    propertyTitle: 'Cozy Studio in Bastos',
    landlordId: 'landlord_001',
    tenantId: 'tenant_002',
    tenantName: 'Bob Smith',
    amount: 300000,
    month: 'August 2026',
    status: 'pending',
    type: 'deposit',
    description: 'Security deposit payment',
    createdAt: DateTime(2026, 8, 3),
  ),
  PaymentModel(
    id: 'pay_004',
    propertyId: 'prop_001',
    propertyTitle: 'Modern 2 Bedroom Apartment',
    landlordId: 'landlord_001',
    tenantId: 'tenant_001',
    tenantName: 'Alice Johnson',
    amount: 25000,
    month: 'July 2026',
    status: 'approved',
    type: 'maintenance',
    description: 'Plumbing repair reimbursement',
    createdAt: DateTime(2026, 7, 20),
  ),
  PaymentModel(
    id: 'pay_005',
    propertyId: 'prop_002',
    propertyTitle: 'Cozy Studio in Bastos',
    landlordId: 'landlord_001',
    tenantId: 'tenant_002',
    tenantName: 'Bob Smith',
    amount: 80000,
    month: 'June 2026',
    status: 'approved',
    type: 'rent',
    description: 'Monthly rent payment for June 2026',
    createdAt: DateTime(2026, 6, 1),
  ),
  PaymentModel(
    id: 'pay_006',
    propertyId: 'prop_001',
    propertyTitle: 'Modern 2 Bedroom Apartment',
    landlordId: 'landlord_001',
    tenantId: 'tenant_003',
    tenantName: 'Camille Ndongo',
    amount: 150000,
    month: 'August 2026',
    status: 'rejected',
    type: 'rent',
    description: 'August 2026 rent — rejected due to incomplete reference',
    createdAt: DateTime(2026, 8, 2),
  ),
];

// ── Notifier ──────────────────────────────────────────────────────────────────
class PaymentsNotifier extends Notifier<List<PaymentModel>> {
  @override
  List<PaymentModel> build() => List.from(_seedPayments);

  void approvePayment(String paymentId) {
    state = state.map((p) => p.id == paymentId ? p.copyWith(status: 'approved') : p).toList();
  }

  void rejectPayment(String paymentId) {
    state = state.map((p) => p.id == paymentId ? p.copyWith(status: 'rejected') : p).toList();
  }

  void addPayment(PaymentModel payment) {
    state = [payment, ...state];
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final paymentsProvider = NotifierProvider<PaymentsNotifier, List<PaymentModel>>(() => PaymentsNotifier());

final landlordPaymentsProvider = Provider.family<List<PaymentModel>, String>((ref, landlordId) {
  final all = ref.watch(paymentsProvider);
  return all.where((p) => p.landlordId == landlordId).toList();
});

final pendingPaymentsProvider = Provider.family<List<PaymentModel>, String>((ref, landlordId) {
  final all = ref.watch(landlordPaymentsProvider(landlordId));
  return all.where((p) => p.status == 'pending').toList();
});

final approvedPaymentsProvider = Provider.family<List<PaymentModel>, String>((ref, landlordId) {
  final all = ref.watch(landlordPaymentsProvider(landlordId));
  return all.where((p) => p.status == 'approved').toList();
});

final totalRevenueProvider = Provider.family<double, String>((ref, landlordId) {
  final approved = ref.watch(approvedPaymentsProvider(landlordId));
  return approved.fold(0.0, (sum, p) => sum + p.amount);
});
