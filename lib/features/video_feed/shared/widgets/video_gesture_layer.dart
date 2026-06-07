import 'package:flutter/material.dart';
import '../animations/tap_heart_overlay_manager.dart';

class VideoGestureLayer extends StatelessWidget {
  final Widget child;

  const VideoGestureLayer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      // Fix: onDoubleTapDown alone does not win the gesture arena on all
      // Flutter versions — the recogniser only commits when onDoubleTap is
      // also provided. Keep onDoubleTapDown for the position, and declare
      // onDoubleTap so the recogniser claims the gesture.
      onDoubleTapDown: (details) {
        final overlay = Overlay.of(context);
        final manager = TapHeartOverlayManager(overlay);
        manager.showHeart(details.globalPosition);
      },
      onDoubleTap: () {
        // Gesture claimed — actual work is done in onDoubleTapDown above.
      },

      child: child,
    );
  }
}