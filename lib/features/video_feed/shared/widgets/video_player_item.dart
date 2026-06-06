import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/video_model.dart';
import '../../controller/video_feed_controller.dart';
import '../paywall/paywall_manager.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoFeedController controller;
  final int index;
  final VideoModel video;

  const VideoPlayerItem({
    super.key,
    required this.controller,
    required this.index,
    required this.video,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _videoController;
  late PaywallManager paywallManager;

  bool _paywallTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final overlay = Overlay.of(context);
    paywallManager = PaywallManager(overlay);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ctrl = await widget.controller.pool.getController(
      widget.index,
      widget.video,
    );

    setState(() {
      _videoController = ctrl;
    });

    if (widget.index == widget.controller.currentIndex) {
      await ctrl.play();

      _startPaywallTimer(ctrl);
    }
  }

  void _startPaywallTimer(VideoPlayerController controller) {
    if (_paywallTriggered) return;

    _paywallTriggered = true;

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (!controller.value.isPlaying) return;

      controller.pause();
      paywallManager.show();
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_videoController == null) return;

    if (widget.index == widget.controller.currentIndex) {
      _videoController!.play();
      _startPaywallTimer(_videoController!);
    } else {
      _videoController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null ||
        !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}