import 'package:flutter/material.dart';
import '../model/scrub_state.dart';

class ScrubberController extends ValueNotifier<ScrubState> {
  Duration videoDuration;
 
  ScrubberController({
    required this.videoDuration,
  }) : super(
          ScrubState(
            progress: 0,
            position: Duration.zero,
            isDragging: false,
            dragPosition: Offset.zero,
          ),
        );
 
  /// Called by [VideoFeedController] when a new video's real duration is known.
  /// Resets progress to zero so the scrubber starts fresh on each video.
  void updateDuration(Duration duration) {
    videoDuration = duration;
    value = ScrubState(
      progress: 0,
      position: Duration.zero,
      isDragging: false,
      dragPosition: Offset.zero,
    );
  }
 
  void updateDrag(Offset localPosition, double width) {
    if (videoDuration == Duration.zero) return;
 
    final progress = (localPosition.dx / width).clamp(0.0, 1.0);
    final position = Duration(
      milliseconds: (videoDuration.inMilliseconds * progress).toInt(),
    );
 
    value = value.copyWith(
      progress: progress,
      position: position,
      isDragging: true,
      dragPosition: localPosition,
    );
  }
 
  void endDrag() {
    value = value.copyWith(isDragging: false);
  }
 
  void syncFromVideo(Duration position) {
    if (videoDuration == Duration.zero) return;
 
    final progress = position.inMilliseconds / videoDuration.inMilliseconds;
 
    value = value.copyWith(
      progress: progress.clamp(0.0, 1.0),
      position: position,
    );
  }
}