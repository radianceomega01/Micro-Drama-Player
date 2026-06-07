import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../model/video_model.dart';
import '../controller/video_controller_pool.dart';
import '../controller/scrubber_controller.dart';

/// Single source of truth for the video feed.
///
/// Supports infinite carousel scrolling: [PageView.builder] is given
/// itemCount = null and starts at [kInitialPage]. Any virtual page index
/// is mapped to a real video via `virtualIndex % videos.length`.
/// The pool is always keyed by the real index (0..length-1) so controllers
/// are reused as the same video comes around again.
class VideoFeedController extends ChangeNotifier {
  final List<VideoModel> videos;
  final ScrubberController scrubberController;
  final void Function() onPaywallTriggered;

  // Start far enough from 0 that the user can scroll upward without hitting
  // a hard boundary. Using a multiple of videos.length keeps the modulo
  // mapping correct from the very first frame.
  static const int kInitialPage = 10000;

  VideoFeedController({
    required this.videos,
    required this.scrubberController,
    required this.onPaywallTriggered,
  });

  late final PageController pageController =
      PageController(initialPage: kInitialPage);

  final VideoControllerPool _pool = VideoControllerPool(poolSize: 3);

  // Virtual page index (0..∞). Use [realIndex] for everything video-related.
  int _virtualIndex = kInitialPage;

  bool _paywallShown = false;
  VoidCallback? _videoListener;

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  /// Maps any virtual page index to the actual video index.
  int realIndexFor(int virtualIndex) => virtualIndex % videos.length;

  int get currentRealIndex => realIndexFor(_virtualIndex);

  /// Called by PageView on every page change.
  Future<void> onPageChanged(int virtualIndex) async {
    _detachVideoListener();
    _pool.get(realIndexFor(_virtualIndex))?.pause();
    _paywallShown = false;

    _virtualIndex = virtualIndex;
    final real = realIndexFor(virtualIndex);

    final ctrl = await _pool.getController(
      real,
      videos[real],
      currentIndex: real,
    );

    if (!ctrl.value.isInitialized) return;

    scrubberController.updateDuration(ctrl.value.duration);
    _attachVideoListener(ctrl);
    await ctrl.seekTo(Duration.zero);
    await ctrl.play();

    // Preload the next real video.
    final nextReal = realIndexFor(virtualIndex + 1);
    _pool
        .getController(nextReal, videos[nextReal], currentIndex: real)
        .catchError((_) {});

    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await activeController?.seekTo(position);

    // Explicitly check the limit right after the seek completes rather than
    // waiting for the listener to fire — the controller may not emit a value
    // update immediately after seekTo on all Android versions.
    if (position >= videos[currentRealIndex].paywallAfter) {
      _handlePaywallTrigger();
    }
  }

  /// Resumes the active video after the paywall is dismissed.
  /// Detaches the listener before seeking so the position-check in the
  /// listener cannot re-trigger the paywall during the async seek gap,
  /// then re-attaches before playing.
  Future<void> resume() async {
    final ctrl = activeController;
    if (ctrl == null) return;

    // Detach listener so no position callbacks fire while we are seeking.
    _detachVideoListener();

    await ctrl.seekTo(Duration.zero);
    scrubberController.syncFromVideo(Duration.zero);

    // Only reset the flag after the seek has landed at zero.
    _paywallShown = false;

    // Re-attach before playing so position updates resume normally.
    _attachVideoListener(ctrl);
    await ctrl.play();
  }

  VideoPlayerController? get activeController =>
      _pool.get(currentRealIndex);

  Future<VideoPlayerController> loadController(int realIndex) =>
      _pool.getController(
        realIndex,
        videos[realIndex],
        currentIndex: currentRealIndex,
      );

  // ──────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────

  void _attachVideoListener(VideoPlayerController ctrl) {
    _videoListener = () {
      if (!ctrl.value.isInitialized) return;

      final position = ctrl.value.position;

      if (!scrubberController.value.isDragging) {
        scrubberController.syncFromVideo(position);
      }

      // Check paywall limit on every frame — this catches both normal
      // playback and scrubber seeks with no timer race condition.
      if (position >= videos[currentRealIndex].paywallAfter) {
        _handlePaywallTrigger();
      }
    };
    ctrl.addListener(_videoListener!);
  }

  void _detachVideoListener() {
    if (_videoListener == null) return;
    _pool.get(currentRealIndex)?.removeListener(_videoListener!);
    _videoListener = null;
  }

  void _handlePaywallTrigger() {
    // Single gate: whichever call site (listener or seekTo) arrives first
    // flips the flag and fires — the second call returns immediately.
    if (_paywallShown) return;
    _paywallShown = true;

    final ctrl = activeController;
    if (ctrl == null) return;
    ctrl.pause();
    onPaywallTriggered();
  }

  @override
  void dispose() {
    _detachVideoListener();
    _pool.disposeAll();
    pageController.dispose();
    super.dispose();
  }
}