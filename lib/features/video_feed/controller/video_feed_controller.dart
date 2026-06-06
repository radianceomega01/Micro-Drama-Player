import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../model/video_model.dart';
import '../controller/video_controller_pool.dart';
import '../controller/scrubber_controller.dart';

class VideoFeedController extends ChangeNotifier {
  final PageController pageController = PageController();

  final VideoControllerPool pool = VideoControllerPool(poolSize: 3);

  final List<VideoModel> videos;

  int currentIndex = 0;

  VideoFeedController(this.videos);

  Future<void> onPageChanged(int index) async {
    currentIndex = index;

    // preload current + next
    await pool.getController(index, videos[index]);

    if (index + 1 < videos.length) {
      pool.getController(index + 1, videos[index + 1]);
    }

    notifyListeners();
  }

  void attachScrubber(ScrubberController scrubber) {
  addListener(() {
    final ctrl = activeController;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    scrubber.syncFromVideo(ctrl.value.position);
  });
}

  VideoPlayerController? get activeController => pool.get(currentIndex);

  Duration get activeDuration =>
      activeController?.value.duration ?? Duration.zero;

  Duration get activePosition =>
      activeController?.value.position ?? Duration.zero;

  @override
  void dispose() {
    pool.disposeAll();
    pageController.dispose();
    super.dispose();
  }
}
