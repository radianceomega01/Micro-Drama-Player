import 'dart:ui';
import 'package:flutter/material.dart';
import 'shimmer_button.dart';

class PaywallOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const PaywallOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<PaywallOverlay> createState() => _PaywallOverlayState();
}

class _PaywallOverlayState extends State<PaywallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<Offset> slide;
  late Animation<double> fade;
  late Animation<double> blur;

  bool isClosing = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // 🪄 Slide (entry + exit)
    slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      ),
    );

    // 🌫 Fade background
    fade = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(controller);

    // 🌫 Blur intensity control
    blur = Tween<double>(
      begin: 8,
      end: 0,
    ).animate(controller);

    controller.forward();
  }

  void close() async {
    if (isClosing) return;

    setState(() => isClosing = true);

    // 🔥 reverse all animations
    await controller.reverse();

    // 🧹 remove overlay after animation completes
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 🌫 BACKGROUND (fade + blur unwind)
              Opacity(
                opacity: fade.value.clamp(0.0, 1.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blur.value,
                    sigmaY: blur.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),

              // 🪄 PAYWALL CARD
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: slide,
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Unlock Full Episode",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Continue watching after 10 seconds requires unlock.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 30),

                        const ShimmerButton(),

                        const SizedBox(height: 20),

                        // ❌ CLOSE BUTTON
                        TextButton(
                          onPressed: close,
                          child: const Text(
                            "Not now",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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