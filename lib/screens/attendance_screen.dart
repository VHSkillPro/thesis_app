import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:thesis_app/core/entities/attendance.dart';
import 'package:thesis_app/repositories/attendance_repository.dart';
import 'package:thesis_app/services/attendance_service.dart';
import 'package:thesis_app/widgets/camera_stream_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Attendance> attendances = [];

  void updateAttendances(List<Attendance> newAttendances) {
    List<Attendance> updatedAttendances = [...attendances];
    for (var newAttendance in newAttendances) {
      final index = updatedAttendances.indexWhere(
        (attendance) => attendance.student.id == newAttendance.student.id,
      );
      if (index != -1) {
        // Update existing attendance
        updatedAttendances[index] = newAttendance;
      } else {
        // Add new attendance
        updatedAttendances.add(newAttendance);
      }
    }

    setState(() {
      attendances = updatedAttendances;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hệ thống điểm danh tự động')),
      body: Center(
        child: Column(
          children: [
            CameraStreamWidget(
              cameras: widget.cameras,
              attendanceRepository: AttendanceRepository(
                attendanceService: AttendanceService(),
              ),
              onAttendancesUpdated: updateAttendances,
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: attendances.length,
                itemBuilder: (BuildContext context, int index) {
                  final attendance = attendances[index];
                  return ListTile(
                    title: Text(
                      "${attendance.student.fullname} (${attendance.student.id})",
                    ),
                    subtitle: Text(
                      'Last time: ${attendance.lastAttendanceTime.toLocal()}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
