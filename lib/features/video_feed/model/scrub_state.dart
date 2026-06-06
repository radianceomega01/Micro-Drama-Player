import 'package:flutter/material.dart';

class ScrubState {
  final double progress; // 0.0 - 1.0
  final Duration position;
  final bool isDragging;
  final Offset dragPosition;

  ScrubState({
    required this.progress,
    required this.position,
    required this.isDragging,
    required this.dragPosition,
  });

  ScrubState copyWith({
    double? progress,
    Duration? position,
    bool? isDragging,
    Offset? dragPosition,
  }) {
    return ScrubState(
      progress: progress ?? this.progress,
      position: position ?? this.position,
      isDragging: isDragging ?? this.isDragging,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }
}