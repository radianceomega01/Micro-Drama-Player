import 'dart:async';

/// Pure business logic for the paywall gate.
///
/// The free-watch duration is passed per [arm] call so each video can define
/// its own limit via [VideoModel.paywallAfter].
class PaywallService {
  final void Function() onTrigger;

  PaywallService({required this.onTrigger});

  Timer? _timer;

  /// Starts a countdown of [freeWatchLimit] for the current video.
  /// Cancels any previously running timer before starting a new one.
  void arm({required Duration freeWatchLimit}) {
    cancel();
    _timer = Timer(freeWatchLimit, onTrigger);
  }

  /// Cancels the active timer. Call on every page change so the outgoing
  /// video's countdown cannot fire on the incoming video.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}