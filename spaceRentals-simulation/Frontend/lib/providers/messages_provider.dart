import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/messages/domain/message.dart';
import 'di_providers.dart';

final conversationsProvider = FutureProvider<List<ConversationSummary>>((ref) {
  return ref.watch(messageRepositoryProvider).getConversations();
});

final roomMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((
  ref,
  roomId,
) {
  return ref.watch(messageRepositoryProvider).getRoom(roomId);
});
