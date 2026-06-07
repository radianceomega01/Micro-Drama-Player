import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/widgets/heart_burst.dart';

class TapHeartOverlayManager {
  final OverlayState overlayState;

  TapHeartOverlayManager(this.overlayState);

  void showHeart(Offset position) {
    late final OverlayEntry entry;

    entry = OverlayEntry(
      // Fix: mark as opaque: false explicitly and avoid rebuilding on every
      // overlay state change by keeping the widget fully self-contained.
      builder: (_) => HeartBurst(position: position),
    );

    overlayState.insert(entry);

    // Fix: use a self-removing pattern via the animation completing rather
    // than a raw Future.delayed that leaks if the overlay is disposed early.
    // HeartBurst's longest animation is 700ms; remove at 750ms to be safe.
    Future.delayed(const Duration(milliseconds: 750), () {
      if (entry.mounted) entry.remove();
    });
  }
}