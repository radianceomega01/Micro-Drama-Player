import 'package:flutter/material.dart';
import '../model/video_model.dart';
import '../controller/video_feed_controller.dart';
import '../shared/widgets/video_player_item.dart';
import '../controller/scrubber_controller.dart';
import '../shared/widgets/video_scrubber.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final VideoFeedController controller;

  // Fix: ScrubberController is recreated whenever the active video changes
  // so it always holds the correct duration. The original code created it
  // once with a hardcoded Duration(seconds: 1) placeholder that was never
  // updated, making the scrubber's progress calculation wrong for every video.
  ScrubberController? _scrubberController;

  final videos = [
    VideoModel(
      id: "1",
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "2",
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "3",
      url:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      thumbnail: "",
    ),
  ];

  @override
  void initState() {
    super.initState();

    controller = VideoFeedController(videos);

    // Rebuild the scrubber controller once the first video is initialised
    // and its duration is known.
    controller.addListener(_onFeedChanged);
    controller.onPageChanged(0);
  }

  /// Called whenever [VideoFeedController] notifies (i.e. on page change).
  /// Recreates [_scrubberController] with the real video duration.
  void _onFeedChanged() {
    final duration = controller.activeDuration;

    // Don't recreate if duration is still unknown or unchanged.
    if (duration == Duration.zero) return;
    if (_scrubberController?.videoDuration == duration) return;

    final newScrubber = ScrubberController(videoDuration: duration);
    controller.attachScrubber(newScrubber);

    setState(() {
      _scrubberController?.dispose();
      _scrubberController = newScrubber;
    });
  }

  void _onSeek(Duration position) {
    controller.activeController?.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vertical paging feed
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoPlayerItem(
                controller: controller,
                index: index,
                video: videos[index],
              );
            },
          ),

          // Fix: VideoScrubber was never added to the widget tree in the
          // original code. It is now overlaid at the bottom of the screen.
          if (_scrubberController != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VideoScrubber(
                  controller: _scrubberController!,
                  onSeek: _onSeek,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onFeedChanged);
    _scrubberController?.dispose();
    controller.dispose();
    super.dispose();
  }
}