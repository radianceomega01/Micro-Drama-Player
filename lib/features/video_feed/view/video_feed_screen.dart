import 'package:flutter/material.dart';
import '../model/video_model.dart';
import '../controller/video_feed_controller.dart';
import '../shared/widgets/video_player_item.dart';
import '../controller/scrubber_controller.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final VideoFeedController controller;
  late ScrubberController scrubberController;

  final videos = [
    VideoModel(
      id: "1",
      url: "https://sample-videos.com/video1.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "2",
      url: "https://sample-videos.com/video2.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "3",
      url: "https://sample-videos.com/video3.mp4",
      thumbnail: "",
    ),
  ];

  @override
  void initState() {
    super.initState();

    controller = VideoFeedController(videos);

    scrubberController = ScrubberController(
      videoDuration: const Duration(seconds: 1), // placeholder safe init
    );

    controller.attachScrubber(scrubberController);
    controller.onPageChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
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
    );
  }
}
