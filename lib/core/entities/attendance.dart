import 'package:thesis_app/core/entities/student.dart';

class Attendance {
  late Student student;
  late DateTime lastAttendanceTime;

  Attendance({required this.student, required this.lastAttendanceTime});

  void updateLastAttendanceTime() {
    lastAttendanceTime = DateTime.now();
  }
}
