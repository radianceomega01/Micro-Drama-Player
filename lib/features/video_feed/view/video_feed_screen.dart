import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/data/video_mock_data.dart';
import 'package:micro_drama_player/features/video_feed/shared/paywall/paywall_overlay.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/video_player_item.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/video_scrubber.dart';
import '../controller/video_feed_controller.dart';
import '../controller/scrubber_controller.dart';

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

    _scrubberController = ScrubberController(videoDuration: Duration.zero);

    _feedController = VideoFeedController(
      videos: videos,
      scrubberController: _scrubberController,
      onPaywallTriggered: _showPaywall,
    );

    // Defer the first play until after the first frame so the PageView
    // and its render surface exist before we call play(). Calling it in
    // initState means the VideoPlayerController plays into a null texture,
    // the scrubber moves but nothing is visible on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _feedController.onPageChanged(VideoFeedController.kInitialPage);
    });
  }

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
    _feedController.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _feedController.pageController,
            // itemCount is null → infinite scroll in both directions.
            onPageChanged: _feedController.onPageChanged,
            // Keep one page above and below in the render tree so the
            // video widget is already laid out before the user swipes to it.
            allowImplicitScrolling: true,
            itemBuilder: (context, virtualIndex) {
              final realIndex = _feedController.realIndexFor(virtualIndex);
              return VideoPlayerItem(
                feedController: _feedController,
                // Always pass the real index so the pool key stays stable.
                index: realIndex,
                video: videos[realIndex],
              );
            },
          ),

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