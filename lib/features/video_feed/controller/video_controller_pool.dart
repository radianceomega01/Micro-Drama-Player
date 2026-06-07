import 'package:video_player/video_player.dart';
import '../model/video_model.dart';

/// Maintains a fixed-size pool of [VideoPlayerController]s keyed by real index.
///
/// Concurrent calls for the same index share a single [Future] via
/// [_pending], preventing duplicate initialise() calls that would cause
/// the first video to render an orphaned controller and never play.
class VideoControllerPool {
  final int poolSize;

  VideoControllerPool({this.poolSize = 3});

  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, String> _loadedUrls = {};

  // Guards against concurrent getController calls for the same index.
  final Map<int, Future<VideoPlayerController>> _pending = {};

  Future<VideoPlayerController> getController(
    int index,
    VideoModel video, {
    int currentIndex = 0,
  }) {
    // Reuse completed controller if URL matches.
    if (_controllers.containsKey(index) &&
        _loadedUrls[index] == video.url) {
      return Future.value(_controllers[index]!);
    }

    // If already initialising for this index, return the same future so
    // both callers get the same controller instance when it completes.
    if (_pending.containsKey(index)) {
      return _pending[index]!;
    }

    final future = _initController(index, video, currentIndex: currentIndex);
    _pending[index] = future;

    // Remove from pending map once settled (success or error).
    future.whenComplete(() => _pending.remove(index));

    return future;
  }

  Future<VideoPlayerController> _initController(
    int index,
    VideoModel video, {
    required int currentIndex,
  }) async {
    if (_controllers.length >= poolSize) {
      final evictKey = _controllers.keys.reduce(
        (a, b) =>
            (a - currentIndex).abs() >= (b - currentIndex).abs() ? a : b,
      );
      await _controllers[evictKey]?.dispose();
      _controllers.remove(evictKey);
      _loadedUrls.remove(evictKey);
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.url)
    );

    await controller.initialize();
    controller.setLooping(true);

    _controllers[index] = controller;
    _loadedUrls[index] = video.url;

    return controller;
  }

  VideoPlayerController? get(int index) => _controllers[index];

  Future<void> disposeAll() async {
    for (final c in _controllers.values) {
      await c.dispose();
    }
    _controllers.clear();
    _loadedUrls.clear();
    _pending.clear();
  }
}