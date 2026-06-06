import 'package:flutter/material.dart';
import './paywall_overlay.dart';

class PaywallManager {
  final OverlayState overlayState;

  OverlayEntry? _entry;

  PaywallManager(this.overlayState);

  void show() {
    // prevent multiple overlays
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => PaywallOverlay(
        onClose: dismiss,
      ),
    );

    overlayState.insert(_entry!);
  }

  void dismiss() {
    remove();
  }

  void remove() {
    _entry?.remove();
    _entry = null;
  }
}