import 'package:thesis_app/core/entities/student.dart';

class AttendanceResponseDto {
  final bool success;
  final int statusCode;
  final String? message;
  final Student? student;
  final double? similarity;

  AttendanceResponseDto({
    required this.success,
    required this.statusCode,
    this.message,
    this.student,
    this.similarity,
  });
}
