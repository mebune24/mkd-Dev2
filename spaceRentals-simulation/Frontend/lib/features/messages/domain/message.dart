class ConversationSummary {
  final String roomId;
  final String participantId;
  final String participantName;
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? propertyTitle;

  const ConversationSummary({
    required this.roomId,
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageAt,
    this.propertyTitle,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] is Map
        ? Map<String, dynamic>.from(json['participant'] as Map)
        : const <String, dynamic>{};
    final property = json['property'] is Map
        ? Map<String, dynamic>.from(json['property'] as Map)
        : const <String, dynamic>{};
    return ConversationSummary(
      roomId: json['roomId']?.toString() ?? '',
      participantId: participant['id']?.toString() ?? '',
      participantName: participant['name']?.toString() ?? 'User',
      participantRole: participant['role']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageAt:
          DateTime.tryParse(json['lastMessageAt']?.toString() ?? '') ??
          DateTime.now(),
      propertyTitle: property['title']?.toString(),
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String receiverId;
  final String body;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id']?.toString() ?? '',
    roomId: json['roomId']?.toString() ?? '',
    senderId: json['senderId']?.toString() ?? '',
    receiverId: json['receiverId']?.toString() ?? '',
    body: (json['body'] ?? json['message'])?.toString() ?? '',
    createdAt:
        DateTime.tryParse(
          (json['createdAt'] ?? json['timestamp'])?.toString() ?? '',
        ) ??
        DateTime.now(),
  );
}
