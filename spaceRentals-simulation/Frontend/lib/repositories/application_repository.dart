import '../features/applications/domain/application.dart';

abstract class ApplicationRepository {
  Future<Application> submitApplication(SubmitApplicationRequest request);
  Future<Application> getApplication(String applicationId);
  Future<List<Application>> getTenantApplications();
  Future<List<Application>> getLandlordApplications({String? propertyId});
  Future<Application> withdrawApplication(String applicationId);
  Future<Application> approveApplication(String applicationId, {String? note});
  Future<Application> rejectApplication(String applicationId, {String? note});
}
