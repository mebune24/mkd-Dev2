import '../models/rental_model.dart';
import '../models/payment_model.dart';
import '../models/rnlp_model.dart';

/// MockRentalService simulates the entire rental lifecycle:
/// agreements, payments, and RNLP financing.
///
/// When connecting to a real backend, swap these methods with
/// Supabase or REST API calls — the providers and UI stay unchanged.
class MockRentalService {
  // ------------- Rental Agreements -------------

  Future<RentalModel> getActiveRental(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return RentalModel(
      id: 'rental_001',
      propertyId: 'prop_1',
      tenantId: tenantId,
      landlordId: 'landlord_1',
      rent: 150000,
      deposit: 300000,
      status: AgreementStatus.active,
      tenantConfirmed: true,
      landlordConfirmed: true,
    );
  }

  Future<bool> confirmAgreement(String rentalId, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // simulate successful confirmation
  }

  // ------------- Payments -------------

  Future<List<PaymentModel>> getPayments(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    return [
      PaymentModel(
        id: 'pay_001',
        propertyId: 'prop_001',
        propertyTitle: 'Modern 2-Bedroom Apartment',
        landlordId: 'landlord_1',
        tenantId: tenantId,
        tenantName: 'Mock Tenant',
        amount: 150000,
        month: 'July 2026',
        status: 'approved',
        type: 'rent',
        description: 'Rent – July 2026',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      PaymentModel(
        id: 'pay_002',
        propertyId: 'prop_001',
        propertyTitle: 'Modern 2-Bedroom Apartment',
        landlordId: 'landlord_1',
        tenantId: tenantId,
        tenantName: 'Mock Tenant',
        amount: 150000,
        month: 'August 2026',
        status: 'approved',
        type: 'rent',
        description: 'Rent – August 2026',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  Future<bool> makePayment(String tenantId, double amount, String method) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // simulate gateway success
  }

  // ------------- RNLP Financing -------------

  Future<bool> checkEligibility(String tenantId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // simulate eligibility pass
  }

  Future<RnlpModel> getRnlpContract(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    return RnlpModel(
      id: 'rnlp_001',
      tenantId: tenantId,
      rentalId: 'rental_001',
      financedAmount: 300000,
      remainingBalance: 100000,
      totalMonths: 3,
      monthlyInstalment: 100000,
      status: RnlpStatus.active,
      schedule: [
        RnlpInstalment(month: 1, amount: 100000, paid: true, dueDate: now.subtract(const Duration(days: 30))),
        RnlpInstalment(month: 2, amount: 100000, paid: true, dueDate: now.subtract(const Duration(days: 1))),
        RnlpInstalment(month: 3, amount: 100000, paid: false, dueDate: now.add(const Duration(days: 29))),
      ],
    );
  }

  Future<RnlpModel> applyForRnlp(String tenantId, String rentalId, double depositAmount) async {
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    const months = 3;
    final instalment = depositAmount / months;
    return RnlpModel(
      id: 'rnlp_new_001',
      tenantId: tenantId,
      rentalId: rentalId,
      financedAmount: depositAmount,
      remainingBalance: depositAmount,
      totalMonths: months,
      monthlyInstalment: instalment,
      status: RnlpStatus.active,
      schedule: List.generate(months, (i) => RnlpInstalment(
        month: i + 1,
        amount: instalment,
        paid: false,
        dueDate: now.add(Duration(days: 30 * (i + 1))),
      )),
    );
  }
}
