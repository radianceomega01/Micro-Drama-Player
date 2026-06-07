import 'package:flutter/material.dart';
import '../animations/tap_heart_overlay_manager.dart';

class VideoGestureLayer extends StatelessWidget {
  final Widget child;
 
  /// Called when a double-tap is detected, in addition to showing the
  /// burst animation. Lets the parent react (e.g. toggle a liked state).
  final VoidCallback? onDoubleTap;
 
  const VideoGestureLayer({
    super.key,
    required this.child,
    this.onDoubleTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (details) {
        TapHeartOverlayManager(Overlay.of(context))
            .showHeart(details.globalPosition);
        onDoubleTap?.call();
      },
      onDoubleTap: () {
        // Required alongside onDoubleTapDown so the recogniser claims
        // the gesture arena on all Flutter versions.
      },
      child: child,
    );
  }
}