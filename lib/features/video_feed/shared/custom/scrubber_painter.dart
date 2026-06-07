import 'package:flutter/material.dart';

class ScrubberPainter extends CustomPainter {
  final double progress;
  final bool isDragging;

  ScrubberPainter({
    required this.progress,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = isDragging ? 6 : 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;

    // 🪶 background line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      backgroundPaint,
    );

    // ⚡ progress line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width * progress, centerY),
      progressPaint,
    );

    // 🔵 thumb
    final thumbX = size.width * progress;

    canvas.drawCircle(
      Offset(thumbX, centerY),
      isDragging ? 8 : 5,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant ScrubberPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging;
  }
}