import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/messages/domain/message.dart';

class ApiMessageRepository {
  final ApiClient _client;

  ApiMessageRepository(this._client);

  Future<List<ConversationSummary>> getConversations() async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.messageConversations,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.error?.message ?? 'Failed to load conversations',
      );
    }
    return response.data!
        .map(
          (item) => ConversationSummary.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<ChatMessage>> getRoom(String roomId) async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.messagesRoom(roomId),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load messages');
    }
    return response.data!
        .map(
          (item) =>
              ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> markRead(String roomId) async {
    await _client.patch(ApiEndpoints.messagesRead(roomId));
  }
}
