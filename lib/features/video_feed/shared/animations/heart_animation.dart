import 'package:flutter/material.dart';

class HeartAnimation extends StatefulWidget {
  final Offset position;

  const HeartAnimation({super.key, required this.position});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> opacity;
  late Animation<Offset> floatUp;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    scale = Tween(
      begin: 0.2,
      end: 1.4,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    opacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    floatUp = Tween(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Positioned(
          left: widget.position.dx - 30,
          top: widget.position.dy - 30,
          child: Transform.translate(
            offset: Offset(0, floatUp.value.dy * 50),
            child: Opacity(
              opacity: opacity.value,
              child: Transform.scale(
                scale: scale.value,
                child: const Icon(Icons.favorite, color: Colors.red, size: 60),
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
