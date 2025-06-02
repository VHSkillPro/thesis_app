import 'package:thesis_app/core/entities/student.dart';
import 'package:thesis_app/dto/attendance_response.dart';
import 'package:thesis_app/services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService attendanceService;

  AttendanceRepository({required this.attendanceService});

  Future<AttendanceResponseDto> find(List<double> embedding) async {
    final response = await attendanceService.find(embedding);

    if (response['success']) {
      final student = Student(
        id: response['data']['student']['username'],
        fullname: response['data']['student']['fullname'],
        course: response['data']['student']['course'],
        className: response['data']['student']['class_name'],
        isActive: response['data']['student']['is_active'] ?? true,
      );

      return AttendanceResponseDto(
        success: true,
        statusCode: response['statusCode'],
        student: student,
        similarity: response['data']['student']['similarity'],
      );
    } else {
      return AttendanceResponseDto(
        success: false,
        statusCode: response['statusCode'],
        message: response['message'],
      );
    }
  }
}
