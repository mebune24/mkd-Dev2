import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_endpoints.dart';
import '../../services/session_storage_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Map<String, String>> get _headers async {
    final token = await SessionStorageService.instance.getAccessToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  /// Uploads an image or file to Supabase via the backend storage route.
  /// Returns the relative path stored in Supabase.
  Future<String> uploadFile(XFile file, String bucket) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiEndpoints.baseUrl}/api/storage/upload'),
    );
    request.headers.addAll(await _headers);
    request.fields['bucket'] = bucket;

    // For Web, we must read as bytes
    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
      contentType: _contentTypeFor(file.name),
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      return body['path'] as String;
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  MediaType? _contentTypeFor(String filename) {
    final name = filename.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (name.endsWith('.png')) return MediaType('image', 'png');
    if (name.endsWith('.webp')) return MediaType('image', 'webp');
    return null;
  }

  /// Optional: bulk upload for convenience
  Future<List<String>> uploadMultipleFiles(
    List<XFile> files,
    String bucket,
  ) async {
    List<String> paths = [];
    for (var file in files) {
      final path = await uploadFile(file, bucket);
      paths.add(path);
    }
    return paths;
  }

  Future<Uint8List> downloadFile(String path, String bucket) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/api/storage/download',
    ).replace(queryParameters: {'bucket': bucket, 'path': path});
    final response = await http.get(uri, headers: await _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.body}');
    }
    return response.bodyBytes;
  }

  /// Asks the backend to remove KYC files that were uploaded during a failed
  /// submission. The server refuses to delete any file referenced by a KYC row.
  Future<void> cleanupFailedKycUploads(List<String> paths) async {
    if (paths.isEmpty) return;
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}/api/storage/kyc-orphans'),
      headers: {'Content-Type': 'application/json', ...await _headers},
      body: json.encode({'paths': paths}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to clean up incomplete KYC uploads.');
    }
  }
}
