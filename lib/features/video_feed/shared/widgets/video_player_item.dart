import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/video_gesture_layer.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../controller/video_feed_controller.dart';
//import '../paywall/paywall_manager.dart';

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
  bool _liked = false;
 
  // Animation controller for the heart icon scale bounce on like.
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    lowerBound: 0.8,
    upperBound: 1.2,
  );
 
  @override
  void initState() {
    super.initState();
    _load();
  }
 
  Future<void> _load() async {
    final ctrl = await widget.feedController.loadController(widget.index);
    if (!mounted) return;
    setState(() => _videoController = ctrl);
  }
 
  void _onDoubleTap() {
    setState(() => _liked = true);
    // Bounce: grow then shrink back to 1.0.
    _heartController.forward().then((_) => _heartController.reverse());
  }
 
  @override
  Widget build(BuildContext context) {
    final ctrl = _videoController;
 
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
 
    return VideoGestureLayer(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        children: [
          // Full-screen video
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: ctrl.value.size.width,
                height: ctrl.value.size.height,
                child: VideoPlayer(ctrl),
              ),
            ),
          ),
 
          // Bottom overlay: title + hint (left), heart icon (right)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left side: title + double tap hint
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Double tap to like",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.favorite, color: Colors.white70, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
 
                const SizedBox(width: 12),
 
                // Right side: liked heart icon
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