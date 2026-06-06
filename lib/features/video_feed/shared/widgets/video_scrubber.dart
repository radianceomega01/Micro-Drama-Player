import 'package:flutter/material.dart';
import '../../controller/scrubber_controller.dart';
import '../custom/scrubber_painter.dart';

class VideoScrubber extends StatefulWidget {
  final ScrubberController controller;
  final Function(Duration) onSeek;

  const VideoScrubber({
    super.key,
    required this.controller,
    required this.onSeek,
  });

  @override
  State<VideoScrubber> createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<VideoScrubber>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> heightAnim;

  @override
  void initState() {
    super.initState();

    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    heightAnim = Tween<double>(begin: 40, end: 70).animate(
      CurvedAnimation(parent: expandController, curve: Curves.easeOut),
    );
  }

  void _onStart() {
    expandController.forward();
  }

  void _onEnd() {
    expandController.reverse();
    widget.controller.endDrag();

    widget.onSeek(widget.controller.value.position);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          onHorizontalDragStart: (_) => _onStart(),

          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final width = box.size.width;

            final local = box.globalToLocal(details.globalPosition);

            widget.controller.updateDrag(local, width);
          },

          onHorizontalDragEnd: (_) => _onEnd(),

          child: SizedBox(
            height: heightAnim.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 🎨 CUSTOM PAINTER
                CustomPaint(
                  size: Size.infinite,
                  painter: ScrubberPainter(
                    progress: state.progress,
                    isDragging: state.isDragging,
                  ),
                ),

                // 🕒 TIME BUBBLE
                if (state.isDragging)
                  Positioned(
                    left: state.dragPosition.dx - 30,
                    top: -30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _format(state.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }
}