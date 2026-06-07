import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/video_gesture_layer.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../controller/video_feed_controller.dart';
//import '../paywall/paywall_manager.dart';

/// Pure display widget for a single feed page.
///
/// It asks [VideoFeedController] to load its controller, then renders it.
/// All decisions about play, pause, seek, and paywall live in the controller.
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
 
class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _videoController;
 
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
 
  @override
  Widget build(BuildContext context) {
    final ctrl = _videoController;
 
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
 
    return VideoGestureLayer(
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
 
          // Hint label
          const Positioned(
            bottom: 80,
            left: 20,
            child: Text(
              "Double tap to like ❤️",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}