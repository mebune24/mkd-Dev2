import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/di_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/messages_provider.dart';
import '../../services/socket_service.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(isFr ? 'Messages' : 'Messages'),
        foregroundColor: const Color(0xFF303030),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = conversations[index];
              final lastTime = DateFormat('h:mm a').format(chat.lastMessageAt);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Colors.primaries[index % Colors.primaries.length],
                  child: Text(
                    chat.participantName.isNotEmpty
                        ? chat.participantName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  chat.participantName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat.propertyTitle != null &&
                        chat.propertyTitle!.isNotEmpty)
                      Text(
                        chat.propertyTitle!,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (chat.propertyTitle != null &&
                        chat.propertyTitle!.isNotEmpty)
                      const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                onTap: () {
                  context.push(
                    '/chat/${chat.roomId}',
                    extra: {
                      'id': chat.roomId,
                      'roomId': chat.roomId,
                      'receiverId': chat.participantId,
                      'name': chat.participantName,
                      'property': chat.propertyTitle ?? '',
                      'unread': 0,
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Could not load conversations\n${error.toString()}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> chatData;
  const ChatDetailScreen({super.key, required this.chatData});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _liveMessages = [];
  final ScrollController _scrollController = ScrollController();

  late String _roomId;
  late String _receiverId;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    final rawId = widget.chatData['roomId'] ?? widget.chatData['id'];
    _roomId = rawId?.toString() ?? '';
    _receiverId = widget.chatData['receiverId']?.toString() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUserId = ref.read(authProvider).session?.userId ?? '';
      final token = ref.read(authProvider).session?.accessToken ?? '';
      if (_roomId.isEmpty) return;

      final socketSvc = ref.read(socketServiceProvider);
      if (token.isNotEmpty) {
        socketSvc.connect(token);
      }
      socketSvc.joinRoom(_roomId);
      socketSvc.onMessage((data) {
        if (!mounted) return;
        if (data['roomId']?.toString() != _roomId) return;

        setState(() {
          _liveMessages.add({
            'text': (data['message'] ?? data['body'])?.toString() ?? '',
            'isMe': (data['senderId'] ?? '').toString() == _currentUserId,
            'time': DateFormat('h:mm a').format(DateTime.now()),
          });
        });
        _scrollToBottom();
      });

      ref.read(messageRepositoryProvider).markRead(_roomId);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _receiverId.isEmpty) return;

    ref
        .read(socketServiceProvider)
        .sendMessage(roomId: _roomId, message: text, receiverId: _receiverId);

    setState(() {
      _liveMessages.add({
        'text': text,
        'isMe': true,
        'time': DateFormat('h:mm a').format(DateTime.now()),
      });
    });
    _scrollToBottom();
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socketSvc = ref.watch(socketServiceProvider);
    final currentUserId =
        ref.watch(authProvider).session?.userId ?? _currentUserId;
    final roomAsync = ref.watch(roomMessagesProvider(_roomId));
    final remoteMessages = roomAsync.when(
      data: (messages) => messages
          .map(
            (message) => {
              'text': message.body,
              'isMe': message.senderId == currentUserId,
              'time': DateFormat('h:mm a').format(message.createdAt),
            },
          )
          .toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );
    final allMessages = [...remoteMessages, ..._liveMessages];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.chatData['name']?.toString() ?? 'Conversation',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                if (socketSvc.isConnected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            if (widget.chatData['property'] != null &&
                widget.chatData['property'].toString().isNotEmpty)
              Text(
                widget.chatData['property'].toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: roomAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final msg = allMessages[index];
                      final isMe = msg['isMe'] as bool;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(16),
                              bottomLeft: isMe
                                  ? const Radius.circular(16)
                                  : const Radius.circular(0),
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'] as String,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['time'] as String,
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
