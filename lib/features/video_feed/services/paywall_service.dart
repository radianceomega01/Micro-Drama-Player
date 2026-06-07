/// Pure business logic for the paywall gate.
///
/// Knows nothing about overlays, widgets, or Flutter's rendering tree.
/// The controller owns this; the screen/widget layer reacts to [onTrigger].
class PaywallService {
  final Duration freeWatchLimit;
  final void Function() onTrigger;

  PaywallService({
    this.freeWatchLimit = const Duration(seconds: 10),
    required this.onTrigger,
  });

  bool _triggered = false;

  /// Call this when a video starts (or resumes) playing.
  /// Schedules the paywall after [freeWatchLimit] unless already triggered.
  void arm() {
    if (_triggered) return;
    _triggered = true;

    Future.delayed(freeWatchLimit, () {
      onTrigger();
    });
  }

  /// Reset so the paywall can fire again (e.g. after page change).
  void reset() {
    _triggered = false;
  }
}