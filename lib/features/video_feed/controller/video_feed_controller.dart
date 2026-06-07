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

  // Fix: track the listener we attach to the VideoPlayerController so we
  // can remove it cleanly when the page changes.
  VoidCallback? _videoPositionListener;
  ScrubberController? _attachedScrubber;

  VideoFeedController(this.videos);

  Future<void> onPageChanged(int index) async {
    currentIndex = index;

    // Detach position listener from the previous video controller.
    _detachVideoListener();

    final ctrl = await pool.getController(index, videos[index]);

    // Re-attach to the new controller so the scrubber tracks it.
    _reattachVideoListener(ctrl);

    // Preload next video (fire-and-forget; errors are intentionally ignored).
    if (index + 1 < videos.length) {
      pool
          .getController(index + 1, videos[index + 1])
          .catchError((_) {});
    }

    notifyListeners();
  }

  /// Call once after construction to keep [scrubber] in sync with playback.
  // Fix: the old implementation added a listener to *this* ChangeNotifier,
  // which only fires when notifyListeners() is called (e.g. on page change).
  // It never fired during normal video playback, so the scrubber never
  // updated. We now listen directly to the VideoPlayerController whose
  // value changes every frame during playback.
  void attachScrubber(ScrubberController scrubber) {
    _attachedScrubber = scrubber;

    final ctrl = pool.get(currentIndex);
    if (ctrl != null) {
      _reattachVideoListener(ctrl);
    }
  }

  void _reattachVideoListener(VideoPlayerController ctrl) {
    if (_attachedScrubber == null) return;

    final scrubber = _attachedScrubber!;

    _videoPositionListener = () {
      if (!ctrl.value.isInitialized) return;
      scrubber.syncFromVideo(ctrl.value.position);
    };

    ctrl.addListener(_videoPositionListener!);
  }

  void _detachVideoListener() {
    if (_videoPositionListener == null) return;

    final ctrl = pool.get(currentIndex);
    ctrl?.removeListener(_videoPositionListener!);
    _videoPositionListener = null;
  }

  VideoPlayerController? get activeController => pool.get(currentIndex);

  Duration get activeDuration =>
      activeController?.value.duration ?? Duration.zero;

  Duration get activePosition =>
      activeController?.value.position ?? Duration.zero;

  @override
  void dispose() {
    _detachVideoListener();
    pool.disposeAll();
    pageController.dispose();
    super.dispose();
  }
}