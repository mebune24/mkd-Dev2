import '../features/properties/domain/property.dart';
import '../shared/models/enums.dart';

abstract class VerificationRepository {
  Future<List<PropertyWithListing>> getPendingVerifications();
  Future<PropertyVerificationInfo> verifyProperty(String propertyId, PropertyVerificationLevel level);
  Future<PropertyVerificationInfo> getVerificationInfo(String propertyId);
}
