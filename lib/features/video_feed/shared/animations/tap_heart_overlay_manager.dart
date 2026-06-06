import 'package:flutter/material.dart';
import '../widgets/heart_burst.dart';

class TapHeartOverlayManager {
  final OverlayState overlayState;

  TapHeartOverlayManager(this.overlayState);

  void showHeart(Offset position) {
    final entry = OverlayEntry(
      builder: (context) {
        return HeartBurst(position: position);
      },
    );

    overlayState.insert(entry);

    Future.delayed(const Duration(milliseconds: 800), () {
      entry.remove();
    });
  }
}