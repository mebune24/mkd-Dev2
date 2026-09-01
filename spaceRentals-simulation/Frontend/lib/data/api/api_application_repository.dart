import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/applications/domain/application.dart';
import '../../repositories/application_repository.dart';
import '../../shared/models/enums.dart';

/// ApiApplicationRepository
///
/// Connects to the real Node.js/Express backend for all application operations.
/// Replaces MockApplicationRepository — every call hits the live PostgreSQL DB.
class ApiApplicationRepository implements ApplicationRepository {
  final ApiClient _apiClient;

  ApiApplicationRepository(this._apiClient);

  Application _fromJson(Map<String, dynamic> j) {
    // Map backend status strings → frontend enum
    ApplicationStatus status;
    switch (j['status']) {
      case 'submitted':     status = ApplicationStatus.submitted; break;
      case 'under_review':  status = ApplicationStatus.underReview; break;
      case 'approved':      status = ApplicationStatus.approved; break;
      case 'rejected':      status = ApplicationStatus.rejected; break;
      case 'withdrawn':     status = ApplicationStatus.withdrawn; break;
      default:              status = ApplicationStatus.submitted;
    }

    final property = j['property'] as Map<String, dynamic>?;
    final tenant   = j['tenant']   as Map<String, dynamic>?;

    return Application(
      id:            j['id'] ?? '',
      tenantId:      j['tenantId'] ?? '',
      tenantName:    tenant?['name'] ?? '',
      propertyId:    j['propertyId'] ?? '',
      propertyTitle: property?['title'] ?? '',
      landlordId:    property?['landlordId'] ?? '',
      status:        status,
      coverLetter:      j['coverLetter'],
      nationalIdUrl:    j['nationalIdUrl'],
      proofOfIncomeUrl: j['proofOfIncomeUrl'],
      landlordNote:     j['landlordNote'],
      submittedAt: DateTime.tryParse(j['submittedAt'] ?? '') ?? DateTime.now(),
      updatedAt:   DateTime.tryParse(j['updatedAt']   ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<Application> submitApplication(SubmitApplicationRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.applications,
      data: {
        'propertyId':       request.propertyId,
        'coverLetter':      request.coverLetter,
        'nationalIdUrl':    request.nationalIdUrl,
        'proofOfIncomeUrl': request.proofOfIncomeUrl,
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to submit application');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Application> getApplication(String applicationId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.application(applicationId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Application not found');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<List<Application>> getTenantApplications() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiEndpoints.applications}/tenant',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load applications');
    }
    return response.data!.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Application>> getLandlordApplications({String? propertyId}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiEndpoints.applications}/landlord',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load applications');
    }
    var applications = response.data!.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    if (propertyId != null) {
      applications = applications.where((a) => a.propertyId == propertyId).toList();
    }
    return applications;
  }

  @override
  Future<Application> withdrawApplication(String applicationId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.withdrawApplication(applicationId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to withdraw application');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Application> approveApplication(String applicationId, {String? note}) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.approveApplication(applicationId),
      data: {'note': note},
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to approve application');
    }
    return _fromJson(response.data!);
  }

  @override
  Future<Application> rejectApplication(String applicationId, {String? note}) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.rejectApplication(applicationId),
      data: {'note': note},
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to reject application');
    }
    return _fromJson(response.data!);
  }
}
