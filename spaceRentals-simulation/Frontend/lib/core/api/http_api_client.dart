import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../errors/app_failure.dart';
import '../../services/session_storage_service.dart';

class HttpApiClient implements ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SessionStorageService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  ApiResponse<T> _processResponse<T>(
      http.Response response, T Function(Map<String, dynamic>)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        if (fromJson != null && decoded is Map<String, dynamic>) {
          return ApiResponse.success(fromJson(decoded), statusCode: response.statusCode);
        }
        // Return raw decoded value (List or Map) as T
        return ApiResponse.success(decoded as T, statusCode: response.statusCode);
      } catch (_) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }
    } else {
      String errorMessage = 'An unexpected error occurred.';
      try {
        final decoded = json.decode(response.body);
        errorMessage = decoded['message'] ?? errorMessage;
      } catch (_) {}

      if (response.statusCode == 401) {
        SessionStorageService.instance.clearSession();
        errorMessage = 'Your session has expired. Please sign in again.';
      }

      return ApiResponse.failure(
        ServerFailure(errorMessage),
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParameters);
      final headers = await _getHeaders();
      final response = await _client.get(uri, headers: headers);
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.failure(UnknownFailure(e.toString()), statusCode: 500);
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParameters);
      final headers = await _getHeaders();
      final response = await _client.post(uri, headers: headers, body: data != null ? json.encode(data) : null);
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.failure(UnknownFailure(e.toString()), statusCode: 500);
    }
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(path);
      final headers = await _getHeaders();
      final response = await _client.patch(uri, headers: headers, body: data != null ? json.encode(data) : null);
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.failure(UnknownFailure(e.toString()), statusCode: 500);
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(path);
      final headers = await _getHeaders();
      final response = await _client.delete(uri, headers: headers, body: data != null ? json.encode(data) : null);
      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.failure(UnknownFailure(e.toString()), statusCode: 500);
    }
  }
}
