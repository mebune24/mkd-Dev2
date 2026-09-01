import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class PaymentInitiationResponse {
  final String transactionId;
  final String gatewayTxId;
  final String? paymentLink;

  PaymentInitiationResponse({
    required this.transactionId,
    required this.gatewayTxId,
    this.paymentLink,
  });

  factory PaymentInitiationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationResponse(
      transactionId: json['transactionId'] ?? '',
      gatewayTxId: json['gatewayTxId'] ?? '',
      paymentLink: json['paymentLink'],
    );
  }
}

class TransactionRecord {
  final String id;
  final int amount;
  final String currency;
  final String paymentMethod;
  final String transactionType;
  final String status;
  final DateTime createdAt;

  TransactionRecord({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.transactionType,
    required this.status,
    required this.createdAt,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'XAF',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionType: json['transactionType'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ApiPaymentRepository {
  final ApiClient _apiClient;

  ApiPaymentRepository(this._apiClient);

  Future<PaymentInitiationResponse> initiatePayment({
    required int amount,
    required String email,
    String? phoneNumber,
    required String message,
    required String referenceType,
    required String referenceId,
    required String paymentMethod,
    String? redirectUrl,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/payments/initiate',
      data: {
        'amount': amount,
        'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'message': message,
        'referenceType': referenceType,
        'referenceId': referenceId,
        'paymentMethod': paymentMethod,
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to initiate payment');
    }

    return PaymentInitiationResponse.fromJson(response.data!);
  }

  Future<List<TransactionRecord>> getMyTransactions() async {
    final response = await _apiClient.get<List<dynamic>>('/payments/transactions');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load transactions');
    }

    return response.data!
        .map((j) => TransactionRecord.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
