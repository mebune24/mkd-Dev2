import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:video_player/video_player.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/tenant/domain/video_feed_item.dart';
import '../../providers/di_providers.dart';
import '../../providers/property_provider.dart';
import '../../services/session_storage_service.dart';
import '../../core/utils/currency_formatter.dart';

class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  late final PageController _pageController;
  io.Socket? _socket;
  List<VideoFeedItem> _items = [];
  int _nextPage = 2;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    final token = await SessionStorageService.instance.getAccessToken();
    if (!mounted || token == null || token.isEmpty) return;

    final socket = io.io(
      ApiEndpoints.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    socket.on('property_feed_updated', (_) {
      if (mounted) _refreshFeed();
    });
    socket.on('property_engagement_updated', (payload) {
      if (mounted && payload is Map) _applyEngagementUpdate(payload);
    });
    socket.connect();
    _socket = socket;
  }

  void _applyEngagementUpdate(Map payload) {
    final propertyId = payload['propertyId']?.toString();
    if (propertyId == null) return;
    final index = _items.indexWhere((item) => item.propertyId == propertyId);
    if (index < 0) return;
    final current = _items[index];
    final nextEngagement = FeedEngagement(
      likes: (payload['likes'] as num?)?.toInt() ?? current.engagement.likes,
      comments:
          (payload['comments'] as num?)?.toInt() ?? current.engagement.comments,
      reshares:
          (payload['reshares'] as num?)?.toInt() ?? current.engagement.reshares,
      likedByMe: current.engagement.likedByMe,
      resharedByMe: current.engagement.resharedByMe,
    );
    setState(
      () => _items[index] = current.copyWith(engagement: nextEngagement),
    );
  }

  @override
  void dispose() {
    _socket?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _items = [];
      _nextPage = 2;
      _hasMore = true;
    });
    ref.invalidate(videoFeedProvider);
  }

  Future<void> _loadMore(List<VideoFeedItem> visibleItems) async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      if (_items.isEmpty) _items = List<VideoFeedItem>.from(visibleItems);
    });
    try {
      final next = await ref
          .read(videoFeedRepositoryProvider)
          .getVideoFeed(page: _nextPage);
      if (!mounted) return;
      setState(() {
        _items.addAll(next.items);
        _nextPage = next.page + 1;
        _hasMore = next.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(videoFeedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: feedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5D3F6A)),
        ),
        error: (error, _) => _FeedMessage(
          title: 'Could not load homes',
          message: error.toString(),
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(videoFeedProvider),
        ),
        data: (page) {
          final items = _items.isEmpty ? page.items : _items;
          if (items.isEmpty) {
            return _FeedMessage(
              title: 'No video tours yet',
              message:
                  'New video listings will appear here when landlords publish them.',
              actionLabel: 'Refresh',
              onAction: _refreshFeed,
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF5D3F6A),
            backgroundColor: Colors.white,
            onRefresh: _refreshFeed,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: items.length,
              onPageChanged: (index) {
                if (index >= items.length - 2 && page.hasMore) {
                  _loadMore(items);
                }
              },
              itemBuilder: (context, index) =>
                  _VideoFeedCard(item: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _VideoFeedCard extends ConsumerStatefulWidget {
  final VideoFeedItem item;

  const _VideoFeedCard({required this.item});

  @override
  ConsumerState<_VideoFeedCard> createState() => _VideoFeedCardState();
}

class _VideoFeedCardState extends ConsumerState<_VideoFeedCard> {
  VideoPlayerController? _controller;
  Timer? _videoTimeout;
  bool _failed = false;
  late FeedEngagement _engagement;

  @override
  void initState() {
    super.initState();
    _engagement = widget.item.engagement;
    _videoTimeout = Timer(const Duration(seconds: 15), () {
      if (!mounted || _controller?.value.isInitialized == true) return;
      setState(() => _failed = true);
    });
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.item.videoUrls.first))
          ..setLooping(true)
          ..initialize()
              .then((_) {
                if (!mounted) return;
                _videoTimeout?.cancel();
                setState(() {});
              })
              .catchError((_) {
                if (mounted) setState(() => _failed = true);
              });
  }

  Future<void> _toggleLike() async {
    final response = await ref
        .read(videoFeedRepositoryProvider)
        .toggleLike(widget.item.propertyId);
    if (!mounted || !response.isSuccess || response.data == null) return;
    final data = response.data!;
    setState(() {
      _engagement = FeedEngagement(
        likes: (data['likes'] as num?)?.toInt() ?? _engagement.likes,
        comments: _engagement.comments,
        reshares: _engagement.reshares,
        likedByMe: data['likedByMe'] == true,
        resharedByMe: _engagement.resharedByMe,
      );
    });
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _showLandlordProfile() async {
    context.push(
      '/tenant/landlord/${widget.item.landlordId}',
      extra: {
        'name': widget.item.landlordName,
        'avatarUrl': widget.item.landlordAvatarUrl,
      },
    );
  }

  Future<void> _toggleReshare() async {
    final response = await ref
        .read(videoFeedRepositoryProvider)
        .toggleReshare(widget.item.propertyId);
    if (!mounted || !response.isSuccess || response.data == null) return;
    final data = response.data!;
    setState(() {
      _engagement = FeedEngagement(
        likes: _engagement.likes,
        comments: _engagement.comments,
        reshares: (data['reshares'] as num?)?.toInt() ?? _engagement.reshares,
        likedByMe: _engagement.likedByMe,
        resharedByMe: data['resharedByMe'] == true,
      );
    });
  }

  Future<void> _addComment() async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment on this property'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ask a question or share your thoughts',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Post'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content == null || content.isEmpty || !mounted) return;
    final response = await ref
        .read(videoFeedRepositoryProvider)
        .addComment(widget.item.propertyId, content);
    if (!mounted || !response.isSuccess) return;
    setState(() {
      _engagement = FeedEngagement(
        likes: _engagement.likes,
        comments: _engagement.comments + 1,
        reshares: _engagement.reshares,
        likedByMe: _engagement.likedByMe,
        resharedByMe: _engagement.resharedByMe,
      );
    });
  }

  @override
  void dispose() {
    _videoTimeout?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _VideoFeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.engagement != widget.item.engagement) {
      setState(() => _engagement = widget.item.engagement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final controller = _controller;
    final ready = controller?.value.isInitialized == true && !_failed;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          GestureDetector(
            onTap: _togglePlayback,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else if (_failed && item.images.isNotEmpty)
          Image.network(
            item.images.first,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade900),
          )
        else
          Container(color: Colors.grey.shade900),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.86),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.42, 1],
            ),
          ),
        ),
        if (ready)
          Center(
            child: IconButton(
              tooltip: controller!.value.isPlaying
                  ? 'Pause video'
                  : 'Play video',
              onPressed: _togglePlayback,
              iconSize: 58,
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.42),
              ),
              icon: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _Badge(
                            icon: item.verificationLevel >= 3
                                ? Icons.verified
                                : Icons.home_work_outlined,
                            label: item.verificationLevel >= 3
                                ? 'Verified'
                                : 'Listed',
                            color: item.verificationLevel >= 3
                                ? Colors.greenAccent
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            icon: Icons.videocam_outlined,
                            label: item.category,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${CurrencyFormatter.formatCFA(item.monthlyRent.toDouble())} / month',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.bedrooms} bed  ·  ${item.bathrooms} bath  ·  ${item.landlordName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CreatorBubble(
                      name: item.landlordName,
                      avatarUrl: item.landlordAvatarUrl,
                      onTap: _showLandlordProfile,
                    ),
                    _FeedAction(
                      icon: Icons.favorite,
                      label: _engagement.likes.toString(),
                      active: _engagement.likedByMe,
                      onTap: _toggleLike,
                    ),
                    _FeedAction(
                      icon: Icons.chat_bubble,
                      label: _engagement.comments.toString(),
                      onTap: _addComment,
                    ),
                    _FeedAction(
                      icon: Icons.repeat,
                      label: _engagement.reshares.toString(),
                      active: _engagement.resharedByMe,
                      onTap: _toggleReshare,
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      tooltip: 'Explore property',
                      onPressed: () => context.push(
                        '/tenant/property/${item.propertyId}',
                        extra: item.toPropertyWithListing(),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!ready && !_failed)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text('Loading video...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CreatorBubble extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _CreatorBubble({
    required this.name,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider(avatarUrl);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: image,
          child: image == null
              ? Text(
                  name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  ImageProvider<Object>? _imageProvider(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('data:image/')) {
      final separator = value.indexOf(',');
      if (separator > 0) {
        try {
          return MemoryImage(base64Decode(value.substring(separator + 1)));
        } catch (_) {
          return null;
        }
      }
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    return null;
  }
}

class _FeedAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FeedAction({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          IconButton(
            onPressed: onTap,
            tooltip: label,
            icon: Icon(
              icon,
              color: active ? Colors.redAccent : Colors.white,
              size: 30,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _FeedMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library_outlined,
              color: Colors.grey,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
