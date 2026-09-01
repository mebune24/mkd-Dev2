import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_endpoints.dart';
import '../../services/session_storage_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Map<String, String>> get _headers async {
    final token = await SessionStorageService.instance.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Uploads an image or file to Supabase via the backend storage route.
  /// Returns the relative path stored in Supabase.
  Future<String> uploadFile(XFile file, String bucket) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiEndpoints.baseUrl}/api/storage/upload'));
    request.headers.addAll(await _headers);
    request.fields['bucket'] = bucket;
    
    // For Web, we must read as bytes
    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: file.name);
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

  /// Optional: bulk upload for convenience
  Future<List<String>> uploadMultipleFiles(List<XFile> files, String bucket) async {
    List<String> paths = [];
    for (var file in files) {
      final path = await uploadFile(file, bucket);
      paths.add(path);
    }
    return paths;
  }
}
