import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/video_gesture_layer.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../controller/video_feed_controller.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoFeedController feedController;
  final int index;
  final VideoModel video;

  const VideoPlayerItem({
    super.key,
    required this.feedController,
    required this.index,
    required this.video,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;

  // Fix: start at value 1.0 (neutral scale) so the icon renders correctly
  // before any tap. The old lowerBound: 0.8 caused the icon to appear at
  // 80% scale on first build before any animation ran.
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1.0,
    lowerBound: 0.8,
    upperBound: 1.2,
  );

  bool _liked = false;

  // Cache video size after first init — it never changes and reading
  // ctrl.value.size on every build is unnecessary.
  Size? _videoSize;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ctrl = await widget.feedController.loadController(widget.index);
    if (!mounted) return;
    setState(() {
      _videoController = ctrl;
      _videoSize = ctrl.value.size;
    });
  }

  void _onDoubleTap() {
    // Fix: use ValueNotifier pattern — only the ScaleTransition subtree
    // needs to respond to the like. Avoid setState on the full widget for
    // a simple icon colour toggle.
    if (!_liked) setState(() => _liked = true);
    _heartController
        .forward()
        .then((_) => _heartController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _videoController;
    final size = _videoSize;

    if (ctrl == null || size == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return VideoGestureLayer(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        children: [
          // Full-screen video — size is cached so FittedBox doesn't read
          // ctrl.value on every build.
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: VideoPlayer(ctrl),
              ),
            ),
          ),

          // Bottom overlay: title + hint (left), heart (right)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Double tap to like",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.favorite,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Fix: ScaleTransition is isolated so only it rebuilds
                // during the bounce animation — not the full item.
                ScaleTransition(
                  scale: _heartController,
                  child: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? Colors.red : Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }
}