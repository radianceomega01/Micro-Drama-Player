import 'dart:math';
import 'package:flutter/material.dart';

class HeartParticle extends StatefulWidget {
  final Offset origin;

  const HeartParticle({
    super.key,
    required this.origin,
  });

  @override
  State<HeartParticle> createState() => _HeartParticleState();
}

class _HeartParticleState extends State<HeartParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> opacity;
  late Animation<double> scale;
  late Animation<Offset> movement;

  final Random random = Random();

  late Offset direction;

  @override
  void initState() {
    super.initState();

    // 🎯 random burst direction
    final angle = random.nextDouble() * 2 * pi;
    final distance = 40 + random.nextDouble() * 80;

    direction = Offset(
      cos(angle) * distance,
      sin(angle) * distance,
    );

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    scale = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    movement = Tween(begin: Offset.zero, end: direction).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return Positioned(
          left: widget.origin.dx,
          top: widget.origin.dy,
          child: Transform.translate(
            offset: movement.value,
            child: Opacity(
              opacity: opacity.value,
              child: Transform.scale(
                scale: scale.value,
                child: const Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}