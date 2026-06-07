import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../model/video_model.dart';
import '../controller/video_controller_pool.dart';
import '../controller/scrubber_controller.dart';

/// Single source of truth for the video feed.
///
/// Responsibilities:
///   - Loading and pooling [VideoPlayerController]s
///   - Play / pause / seek of the active video
///   - Keeping [ScrubberController] in sync via a per-frame video listener
///   - Arming / resetting the [PaywallService] on page changes
///
/// The widget layer is pure display — it never calls play/pause or touches
/// the pool directly.
class VideoFeedController extends ChangeNotifier {
  final List<VideoModel> videos;
 
  /// Passed in via the constructor so the dependency is explicit and the
  /// scrubber is always wired up from the very first frame.
  final ScrubberController scrubberController;
 
  /// Called when the paywall should be shown. The screen/widget listens to
  /// this and shows the overlay — keeping UI concerns out of this class.
  final void Function() onPaywallTriggered;
 
  VideoFeedController({
    required this.videos,
    required this.scrubberController,
    required this.onPaywallTriggered,
  }) {
    _paywallService = PaywallService(
      freeWatchLimit: const Duration(seconds: 10),
      onTrigger: _handlePaywallTrigger,
    );
  }
 
  final PageController pageController = PageController();
  final VideoControllerPool _pool = VideoControllerPool(poolSize: 3);
 
  int currentIndex = 0;
 
  late final PaywallService _paywallService;
 
  // Listener attached to the active VideoPlayerController so the scrubber
  // updates every frame during playback — not just on page changes.
  VoidCallback? _videoListener;
 
  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────
 
  /// Called by PageView when the user swipes to a new page.
  Future<void> onPageChanged(int index) async {
    // Pause the video that is leaving.
    _detachVideoListener();
    _pool.get(currentIndex)?.pause();
    _paywallService.reset();
 
    currentIndex = index;
 
    // Load (or reuse) the controller for the incoming page.
    final ctrl = await _pool.getController(
      index,
      videos[index],
      currentIndex: index,
    );
 
    if (!ctrl.value.isInitialized) return;
 
    // Update scrubber duration now that we know the real video length.
    scrubberController.updateDuration(ctrl.value.duration);
 
    _attachVideoListener(ctrl);
    await ctrl.play();
    _paywallService.arm();
 
    // Fire-and-forget preload of the next video; errors are swallowed
    // intentionally — a failed preload is non-fatal.
    if (index + 1 < videos.length) {
      _pool
          .getController(
            index + 1,
            videos[index + 1],
            currentIndex: index,
          )
          .catchError((_) {});
    }
 
    notifyListeners();
  }
 
  /// Seek the active video to [position] (called by the scrubber on drag end).
  Future<void> seekTo(Duration position) async {
    await activeController?.seekTo(position);
  }
 
  // ──────────────────────────────────────────────
  // Convenience getters for the widget layer
  // ──────────────────────────────────────────────
 
  VideoPlayerController? get activeController => _pool.get(currentIndex);
 
  /// Exposes the pool read-only so [VideoPlayerItem] can get a controller
  /// for its own index to render — but never to play/pause/seek.
  VideoPlayerController? controllerForIndex(int index) => _pool.get(index);
 
  /// Initiates loading for [index] if not already in the pool.
  /// Returns the controller once initialised.
  Future<VideoPlayerController> loadController(int index) =>
      _pool.getController(index, videos[index], currentIndex: currentIndex);
 
  // ──────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────
 
  void _attachVideoListener(VideoPlayerController ctrl) {
    _videoListener = () {
      if (!ctrl.value.isInitialized) return;
      // Only sync when not dragging — dragging takes priority.
      if (!scrubberController.value.isDragging) {
        scrubberController.syncFromVideo(ctrl.value.position);
      }
    };
    ctrl.addListener(_videoListener!);
  }
 
  void _detachVideoListener() {
    if (_videoListener == null) return;
    _pool.get(currentIndex)?.removeListener(_videoListener!);
    _videoListener = null;
  }
 
  void _handlePaywallTrigger() {
    // Only fire if this video is still active and actually playing.
    final ctrl = activeController;
    if (ctrl == null || !ctrl.value.isPlaying) return;
 
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