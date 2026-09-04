import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    // Mock chat list
    final List<Map<String, dynamic>> chats = [
      {
        'id': 'chat_1',
        'name': 'Landlord - John Doe',
        'property': 'Modern 2 Bedroom Apartment',
        'lastMessage': 'Yes, the apartment is still available.',
        'time': '10:30 AM',
        'unread': 2,
        'avatarColor': Colors.blue,
      },
      {
        'id': 'chat_2',
        'name': 'Agent - Sarah Smith',
        'property': 'Luxury 3 Bedroom Penthouse',
        'lastMessage': 'When would you like to schedule a visit?',
        'time': 'Yesterday',
        'unread': 0,
        'avatarColor': Colors.teal,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isFr ? 'Messages' : 'Messages'),
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
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: chat['avatarColor'] as Color,
                  child: Text(
                    (chat['name'] as String).substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if ((chat['unread'] as int) > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(chat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['property'] as String,
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chat['lastMessage'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (chat['unread'] as int) > 0 ? Colors.black87 : Colors.grey,
                    fontWeight: (chat['unread'] as int) > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if ((chat['unread'] as int) > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            onTap: () {
              context.push('/chat/${chat['id']}', extra: chat);
            },
          );
        },
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
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello, I am interested in this property.', 'isMe': true, 'time': '10:00 AM'},
    {'text': 'Hello! Thanks for reaching out.', 'isMe': false, 'time': '10:15 AM'},
    {'text': 'Yes, the apartment is still available.', 'isMe': false, 'time': '10:30 AM'},
  ];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Now',
      });
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    
    // Simulate landlord reply
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': 'I will get back to you shortly.',
          'isMe': false,
          'time': 'Now',
        });
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatData['name'], style: const TextStyle(fontSize: 16)),
            Text(widget.chatData['property'], style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? theme.colorScheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10),
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
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
