import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/paywall/paywall_overlay.dart';
import '../controller/video_feed_controller.dart';
import '../shared/widgets/video_player_item.dart';
import '../controller/scrubber_controller.dart';
import '../shared/widgets/video_scrubber.dart';
import '../data/video_mock_data.dart';

/// Thin orchestration screen.
///
/// Creates the controller graph, reacts to paywall triggers by showing the
/// overlay, and composes the feed + scrubber in the widget tree.
/// No play/pause/seek/timer logic lives here.
class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});
 
  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}
 
class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final videos = VideoMockData().videos;
 
  late final ScrubberController _scrubberController;
  late final VideoFeedController _feedController;
 
  OverlayEntry? _paywallEntry;
 
  @override
  void initState() {
    super.initState();
 
    // ScrubberController is constructed with a zero duration; the real
    // duration is pushed in by VideoFeedController.onPageChanged once the
    // video initialises.
    _scrubberController = ScrubberController(
      videoDuration: Duration.zero,
    );
 
    _feedController = VideoFeedController(
      videos: videos,
      scrubberController: _scrubberController,
      onPaywallTriggered: _showPaywall, // UI concern stays in the screen
    );
 
    // Kick off loading and playback of the first video.
    _feedController.onPageChanged(0);
  }
 
  // ─────────────────────────────────────────────
  // Paywall overlay (UI concern — belongs here,
  // not inside a controller or a widget item)
  // ─────────────────────────────────────────────
 
  void _showPaywall() {
    if (_paywallEntry != null) return;
 
    _paywallEntry = OverlayEntry(
      builder: (_) => PaywallOverlay(onClose: _dismissPaywall),
    );
 
    Overlay.of(context).insert(_paywallEntry!);
  }
 
  void _dismissPaywall() {
    _paywallEntry?.remove();
    _paywallEntry = null;
  }
 
  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vertical paging feed
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _feedController.pageController,
            onPageChanged: _feedController.onPageChanged,
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoPlayerItem(
              feedController: _feedController,
              index: index,
              video: videos[index],
            ),
          ),
 
          // Scrubber overlay at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VideoScrubber(
                controller: _scrubberController,
                onSeek: _feedController.seekTo,
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  @override
  void dispose() {
    _paywallEntry?.remove();
    _scrubberController.dispose();
    _feedController.dispose();
    super.dispose();
  }
}