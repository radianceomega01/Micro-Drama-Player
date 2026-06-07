import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../controller/video_feed_controller.dart';
import './video_gesture_layer.dart';

class VideoPlayerTitle extends StatefulWidget {
  final VideoModel video;
  final int index;
  final VideoFeedController feedController;

  const VideoPlayerTitle({
    super.key,
    required this.video,
    required this.index,
    required this.feedController,
  });

  @override
  State<VideoPlayerTitle> createState() => _VideoPlayerTitleState();
}

class _VideoPlayerTitleState extends State<VideoPlayerTitle> {
  late Future<VideoPlayerController> _controllerFuture;

  @override
  void initState() {
    super.initState();

    _controllerFuture = widget.feedController.pool.getController(
      widget.index,
      widget.video,
    );
  }

  @override
  void didUpdateWidget(covariant VideoPlayerTitle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if page changes, refresh controller binding safely
    if (oldWidget.index != widget.index) {
      _controllerFuture = widget.feedController.pool.getController(
        widget.index,
        widget.video,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoGestureLayer(
      child: FutureBuilder<VideoPlayerController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              !snapshot.data!.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final controller = snapshot.data!;

          return Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),

              Positioned(
                bottom: 50,
                left: 20,
                child: const Text(
                  "Double tap to like ❤️",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}