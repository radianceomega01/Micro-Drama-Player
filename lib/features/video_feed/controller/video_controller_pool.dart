import 'package:video_player/video_player.dart';
import '../model/video_model.dart';

class VideoControllerPool {
  final int poolSize;

  VideoControllerPool({this.poolSize = 3});

  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, String> _loadedUrls = {};

  /// Get controller for [index] (reuses existing one when URL matches).
  Future<VideoPlayerController> getController(
    int index,
    VideoModel video,
  ) async {
    // Already loaded for this URL → reuse without re-initialising.
    if (_controllers.containsKey(index) &&
        _loadedUrls[index] == video.url) {
      return _controllers[index]!;
    }

    // Fix: evict the key that is furthest away from [index] rather than
    // always evicting the first-inserted key. The old behaviour could
    // dispose the currently-playing controller (index 0) while index 1 and
    // 2 are loaded, causing a black screen.
    if (_controllers.length >= poolSize) {
      final evictKey = _controllers.keys.reduce(
        (a, b) => (a - index).abs() >= (b - index).abs() ? a : b,
      );
      await _controllers[evictKey]?.dispose();
      _controllers.remove(evictKey);
      _loadedUrls.remove(evictKey);
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(video.url));

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
  }
}