import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/animations/heart_particle.dart';
import 'package:micro_drama_player/features/video_feed/shared/animations/heart_animation.dart';

class HeartBurst extends StatelessWidget {
  final Offset position;

  const HeartBurst({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ❤️ main animation (your existing file)
        HeartAnimation(position: position),

        // 💫 particle burst
        ...List.generate(
          8,
          (_) => HeartParticle(origin: position),
        ),
      ],
    );
  }
}