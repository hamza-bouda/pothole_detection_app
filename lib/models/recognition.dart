import 'dart:ui';

/// Représente une détection YOLO
class Recognition {
  final String label;
  final double score;
  final Rect rect;

  Recognition({
    required this.label,
    required this.score,
    required this.rect,
  });
}