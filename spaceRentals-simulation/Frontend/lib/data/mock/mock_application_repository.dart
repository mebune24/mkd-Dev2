import 'package:uuid/uuid.dart';
import '../../features/applications/domain/application.dart';
import '../../repositories/application_repository.dart';
import '../../shared/models/enums.dart';

const _uuid = Uuid();

class MockApplicationRepository implements ApplicationRepository {
  final List<Application> _applications = [];

  @override
  Future<Application> submitApplication(SubmitApplicationRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final app = Application(
      id: _uuid.v4(),
      tenantId: 'current_tenant',
      tenantName: 'Current Tenant',
      propertyId: request.propertyId,
      propertyTitle: 'Property',
      landlordId: request.landlordId,
      status: ApplicationStatus.submitted,
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _applications.add(app);
    return app;
  }

  @override
  Future<Application> getApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _applications.firstWhere((a) => a.id == applicationId);
  }

  @override
  Future<List<Application>> getTenantApplications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_applications.where((a) => a.tenantId == 'current_tenant'));
  }

  @override
  Future<List<Application>> getLandlordApplications({String? propertyId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_applications.where((a) =>
        a.landlordId == 'current_landlord' &&
        (propertyId == null || a.propertyId == propertyId)));
  }

  @override
  Future<Application> withdrawApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Not found');
    final updated = _applications[index].copyWith(
      status: ApplicationStatus.withdrawn,
      updatedAt: DateTime.now(),
    );
    _applications[index] = updated;
    return updated;
  }

  @override
  Future<Application> approveApplication(String applicationId, {String? note}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Not found');
    final updated = _applications[index].copyWith(
      status: ApplicationStatus.approved,
      landlordNote: note,
      updatedAt: DateTime.now(),
    );
    _applications[index] = updated;
    return updated;
  }

  @override
  Future<Application> rejectApplication(String applicationId, {String? note}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Not found');
    final updated = _applications[index].copyWith(
      status: ApplicationStatus.rejected,
      landlordNote: note,
      updatedAt: DateTime.now(),
    );
    _applications[index] = updated;
    return updated;
  }
}
