import 'package:flutter/material.dart';
import 'package:micro_drama_player/features/video_feed/shared/custom/scrubber_painter.dart';
import '../../controller/scrubber_controller.dart';

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
  late final AnimationController _expandController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<double> _heightAnim = Tween<double>(
    begin: 40,
    end: 70,
  ).animate(CurvedAnimation(parent: _expandController, curve: Curves.easeOut));

  void _onStart() => _expandController.forward();

  void _onEnd() {
    _expandController.reverse();
    widget.controller.endDrag();
    widget.onSeek(widget.controller.value.position);
  }

  @override
  Widget build(BuildContext context) {
    // Fix: split into two AnimatedBuilders so the GestureDetector and outer
    // SizedBox only rebuild when _heightAnim changes (drag start/end),
    // while the inner painter + time bubble rebuild on every scrubber tick.
    // Previously one AnimatedBuilder listened to widget.controller (every
    // video frame) and rebuilt the entire subtree including GestureDetector.
    return AnimatedBuilder(
      animation: _heightAnim,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _onStart(),
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            widget.controller.updateDrag(
              box.globalToLocal(details.globalPosition),
              box.size.width,
            );
          },
          onHorizontalDragEnd: (_) => _onEnd(),
          child: SizedBox(
            height: _heightAnim.value,
            child: child,
          ),
        );
      },
      // The inner subtree only rebuilds when the scrubber value changes.
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: ScrubberPainter(
                  progress: state.progress,
                  isDragging: state.isDragging,
                ),
              ),
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
          );
        },
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }
}