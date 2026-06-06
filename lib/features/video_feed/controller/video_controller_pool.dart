import 'package:video_player/video_player.dart';
import '../model/video_model.dart';

class VideoControllerPool {
  final int poolSize;

  VideoControllerPool({this.poolSize = 3});

  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, String> _loadedUrls = {};

  /// Get controller for index (reuse if possible)
  Future<VideoPlayerController> getController(
    int index,
    VideoModel video,
  ) async {
    // already exists for same video → reuse
    if (_controllers.containsKey(index) &&
        _loadedUrls[index] == video.url) {
      return _controllers[index]!;
    }

    // if pool exceeded → remove oldest
    if (_controllers.length >= poolSize) {
      final firstKey = _controllers.keys.first;
      await _controllers[firstKey]?.dispose();
      _controllers.remove(firstKey);
      _loadedUrls.remove(firstKey);
    }

    final controller = VideoPlayerController.network(video.url);

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