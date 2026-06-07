import 'package:flutter/material.dart';

class HeartAnimation extends StatefulWidget {
  final Offset position;

  const HeartAnimation({super.key, required this.position});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final Animation<double> _scale = Tween(begin: 0.2, end: 1.4).animate(
    CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
  );

  // Fix: use FadeTransition instead of Opacity widget.
  // Opacity forces a new compositing layer on every frame tick, which is
  // expensive. FadeTransition uses the engine's opacity layer and avoids
  // triggering a full repaint of child content.
  late final Animation<double> _opacity = Tween(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );

  late final Animation<double> _floatUp = Tween(begin: 0.0, end: -75.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // Fix: pass the Icon as a static child so it is not rebuilt on every
      // animation tick — only the transforms around it change.
      child: const Icon(Icons.favorite, color: Colors.red, size: 60),
      builder: (_, child) {
        return Positioned(
          left: widget.position.dx - 30,
          top: widget.position.dy - 30,
          child: FadeTransition(
            opacity: _opacity,
            child: Transform.translate(
              offset: Offset(0, _floatUp.value),
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