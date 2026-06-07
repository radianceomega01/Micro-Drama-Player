import 'package:flutter/material.dart';

class ShimmerButton extends StatefulWidget {
  const ShimmerButton({super.key});

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Fix: clamp each stop so the list always stays within [0.0, 1.0].
        // Without clamping, stops like [-0.3] or [1.3] cause a Flutter
        // assertion error ("stops must be in the range 0.0 to 1.0").
        final mid = controller.value;
        final s0 = (mid - 0.3).clamp(0.0, 1.0);
        final s1 = mid.clamp(0.0, 1.0);
        final s2 = (mid + 0.3).clamp(0.0, 1.0);

        return Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: const [
                Colors.purple,
                Colors.pink,
                Colors.purple,
              ],
              stops: [s0, s1, s2],
            ),
          ),
          child: const Center(
            child: Text(
              "Unlock Episode",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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