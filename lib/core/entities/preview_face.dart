import 'package:thesis_app/core/entities/student.dart';

class PreviewFace {
  final double x;
  final double y;
  final double width;
  final double height;
  final double? similarity;
  final Student? student;

  PreviewFace({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.similarity,
    this.student,
  });
}
