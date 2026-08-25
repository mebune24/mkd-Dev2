import '../../shared/models/enums.dart';

sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication required.']);
}

final class AuthorizationFailure extends AppFailure {
  const AuthorizationFailure([super.message = 'You do not have permission to perform this action.']);
}

final class ValidationFailure extends AppFailure {
  final Map<String, List<String>> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure([super.message = 'A conflict occurred.']);
}

final class PaymentFailure extends AppFailure {
  const PaymentFailure([super.message = 'Payment could not be processed.']);
}

final class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'The request timed out.']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
