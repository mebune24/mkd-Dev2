import '../errors/app_failure.dart';

class ApiResponse<T> {
  final T? data;
  final AppFailure? error;
  final int statusCode;

  const ApiResponse.success(this.data, {this.statusCode = 200}) : error = null;
  const ApiResponse.failure(this.error, {required this.statusCode}) : data = null;

  bool get isSuccess => error == null;
}

abstract class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  });
}
