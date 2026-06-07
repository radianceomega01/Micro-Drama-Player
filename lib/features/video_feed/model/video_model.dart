class VideoModel {
  final String id;
  final String url;
  final String title;

  /// How long the user can watch before the paywall is shown.
  /// Defaults to 10 seconds if not specified.
  final Duration paywallAfter;

  VideoModel({
    required this.id,
    required this.url,
    required this.title,
    this.paywallAfter = const Duration(seconds: 10),
  });
}