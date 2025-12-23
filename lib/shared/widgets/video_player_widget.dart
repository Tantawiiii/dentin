import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_placeholder.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool showControls;
  final BoxFit fit;
  final bool isMuted;
  final VoidCallback? onTap;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.fit = BoxFit.cover,
    this.isMuted = false,
    this.onTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _showPlayButton = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final cleanedUrl = widget.videoUrl.trim();
      if (cleanedUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final uri = Uri.parse(cleanedUrl);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw Exception('Invalid video URL scheme: ${uri.scheme}');
      }

      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _errorMessage = null;
        });

        if (widget.autoPlay) {
          _controller!.play();
          _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
          setState(() {
            _isPlaying = true;
            _showPlayButton = false;
          });
        }

        _controller!.addListener(() {
          if (mounted) {
            setState(() {
              _isPlaying = _controller!.value.isPlaying;
            });
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('VideoPlayerWidget: Failed to initialize video');
      debugPrint('VideoPlayerWidget: URL: ${widget.videoUrl}');
      debugPrint('VideoPlayerWidget: Error: $e');
      debugPrint('VideoPlayerWidget: StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
        _showPlayButton = true;
      });
    } else {
      _controller!.play();
      setState(() {
        _showPlayButton = false;
      });
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _errorMessage = null;
      });
      _initializeVideo();
    } else if (_isInitialized && _controller != null) {
      if (oldWidget.isMuted != widget.isMuted) {
        _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
      }
      if (oldWidget.autoPlay != widget.autoPlay) {
        if (widget.autoPlay && !_controller!.value.isPlaying) {
          _controller!.play();
          setState(() {
            _isPlaying = true;
            _showPlayButton = false;
          });
        } else if (!widget.autoPlay && _controller!.value.isPlaying) {
          _controller!.pause();
          setState(() {
            _isPlaying = false;
            _showPlayButton = true;
          });
        }
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
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: 8.h),
              Text(
                'Failed to load video',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null && _errorMessage!.length < 100) ...[
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: widget.fit,
              placeholder: (context, url) => ShimmerPlaceholder(
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      );
    }

    return Bounce(
      onTap: widget.onTap ?? _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          if (widget.showControls && _showPlayButton)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.sp,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
