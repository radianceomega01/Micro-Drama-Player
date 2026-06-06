import 'package:flutter/material.dart';
import 'features/video_feed/view/video_feed_screen.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const VideoFeedScreen(),
    );
  }
}