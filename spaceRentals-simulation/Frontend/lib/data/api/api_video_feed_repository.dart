import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/tenant/domain/video_feed_item.dart';

class ApiVideoFeedRepository {
  final ApiClient _client;

  ApiVideoFeedRepository(this._client);

  Future<VideoFeedPage> getVideoFeed({int page = 1, int limit = 10}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.videoFeed,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load video feed');
    }
    return VideoFeedPage.fromJson(response.data!);
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleLike(String propertyId) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.propertyLike(propertyId),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleReshare(String propertyId) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.propertyReshare(propertyId),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addComment(
    String propertyId,
    String content,
  ) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.propertyComments(propertyId),
      data: {'content': content},
    );
  }
}
