import 'package:flutter/material.dart';

class ScrubberPainter extends CustomPainter {
  final double progress;
  final bool isDragging;

  ScrubberPainter({
    required this.progress,
    required this.isDragging,
  });

  // Fix: cache Paint objects as static fields — paint() runs on every video
  // frame so allocating new Paint() instances here creates heavy GC pressure.
  static final _bgPaint = Paint()
    ..color = Colors.white24
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  static final _progressPaint = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round;

  static final _thumbPaint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), _bgPaint);

    _progressPaint.strokeWidth = isDragging ? 6 : 3;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width * progress, centerY),
      _progressPaint,
    );

    canvas.drawCircle(
      Offset(size.width * progress, centerY),
      isDragging ? 8 : 5,
      _thumbPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScrubberPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging;
  }
}