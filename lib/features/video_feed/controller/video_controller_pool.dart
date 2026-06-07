import 'package:video_player/video_player.dart';
import '../model/video_model.dart';

/// Maintains a fixed-size pool of [VideoPlayerController]s keyed by feed index.
///
/// Eviction policy: when the pool is full the controller whose index is
/// furthest from [currentIndex] is disposed and removed, ensuring the active
/// and adjacent videos are never accidentally evicted.
class VideoControllerPool {
  final int poolSize;
 
  VideoControllerPool({this.poolSize = 3});
 
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, String> _loadedUrls = {};
 
  /// Returns an initialised, looping controller for [video] at [index].
  /// Reuses the existing controller if the URL matches.
  Future<VideoPlayerController> getController(
    int index,
    VideoModel video, {
    int currentIndex = 0,
  }) async {
    if (_controllers.containsKey(index) &&
        _loadedUrls[index] == video.url) {
      return _controllers[index]!;
    }
 
    if (_controllers.length >= poolSize) {
      // Evict the entry furthest from the currently active index.
      final evictKey = _controllers.keys.reduce(
        (a, b) =>
            (a - currentIndex).abs() >= (b - currentIndex).abs() ? a : b,
      );
      await _controllers[evictKey]?.dispose();
      _controllers.remove(evictKey);
      _loadedUrls.remove(evictKey);
    }
 
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(video.url));
 
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