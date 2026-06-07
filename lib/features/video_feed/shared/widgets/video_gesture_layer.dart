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
 
      // onDoubleTap must be declared alongside onDoubleTapDown so the
      // gesture recogniser claims the arena and the event is not dropped.
      onDoubleTapDown: (details) {
        TapHeartOverlayManager(Overlay.of(context))
            .showHeart(details.globalPosition);
      },
      onDoubleTap: () {
        // Gesture arena claim — work is done in onDoubleTapDown above.
      },
 
      child: child,
    );
  }
}