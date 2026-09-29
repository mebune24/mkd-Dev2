import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedVideoPlayer extends StatefulWidget {
  final String url;
  const CachedVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<CachedVideoPlayer> createState() => _CachedVideoPlayerState();
}

class _CachedVideoPlayerState extends State<CachedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.url.endsWith('.m3u8')) {
        // HLS streams adapt dynamically to 3G/4G natively in video_player
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      } else {
        // For standard MP4s, cache the file locally to save data
        final fileInfo = await DefaultCacheManager().getFileFromCache(widget.url);
        if (fileInfo != null) {
          _controller = VideoPlayerController.file(fileInfo.file);
        } else {
          // If not cached, start downloading to cache while playing directly
          DefaultCacheManager().downloadFile(widget.url);
          _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        }
      }

      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null || _controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text('Failed to load video: $_errorMessage', 
                 style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        )
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller!),
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.blue,
              backgroundColor: Colors.grey,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: !_controller!.value.isPlaying
                    ? const Icon(Icons.play_circle_outline, color: Colors.white, size: 60)
                    : const SizedBox.shrink(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
