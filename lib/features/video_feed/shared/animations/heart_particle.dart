import 'dart:math';
import 'package:flutter/material.dart';

class HeartParticle extends StatefulWidget {
  final Offset origin;

  const HeartParticle({super.key, required this.origin});

  @override
  State<HeartParticle> createState() => _HeartParticleState();
}

class _HeartParticleState extends State<HeartParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _movement;

  @override
  void initState() {
    super.initState();

    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = 40 + random.nextDouble() * 80;
    final direction = Offset(cos(angle) * distance, sin(angle) * distance);

    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scale = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _movement = Tween(begin: Offset.zero, end: direction).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Fix: use FadeTransition instead of Opacity widget to avoid compositing
    // layer allocation on each of the 6 simultaneous particles.
    // Pass the Icon as a static child so it isn't rebuilt every frame.
    return AnimatedBuilder(
      animation: _controller,
      child: const Icon(Icons.favorite, size: 16, color: Colors.pinkAccent),
      builder: (_, child) {
        return Positioned(
          left: widget.origin.dx,
          top: widget.origin.dy,
          child: FadeTransition(
            opacity: _opacity,
            child: Transform.translate(
              offset: _movement.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}