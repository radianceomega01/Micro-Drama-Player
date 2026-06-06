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
      //behavior: HitTestBehavior.opaque,

      onDoubleTapDown: (details) {
        final overlay = Overlay.of(context);

        final manager = TapHeartOverlayManager(overlay);

        manager.showHeart(details.globalPosition);
      },

      child: child,
    );
  }
}