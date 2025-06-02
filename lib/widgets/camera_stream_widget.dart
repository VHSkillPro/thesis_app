import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:path_provider/path_provider.dart';
import 'package:thesis_app/core/config.dart';
import 'package:thesis_app/core/entities/attendance.dart';
import 'package:thesis_app/core/entities/preview_face.dart';
import 'package:thesis_app/core/sface.dart';
import 'package:thesis_app/core/yunet.dart';
import 'package:thesis_app/repositories/attendance_repository.dart';
import 'package:thesis_app/widgets/preview_face_painted.dart';

class CameraStreamWidget extends StatefulWidget {
  const CameraStreamWidget({
    super.key,
    required this.cameras,
    required this.attendanceRepository,
    required this.onAttendancesUpdated,
  });

  // List of available cameras
  final AttendanceRepository attendanceRepository;
  final List<CameraDescription> cameras;
  final void Function(List<Attendance>) onAttendancesUpdated;

  @override
  State<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends State<CameraStreamWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _selectedCamera;
  Future<void>? _initializeControllerFuture;

  bool _isProcessingFrame = false;
  Timer? _frameProcessingTimer;
  final Duration _frameInterval = const Duration(milliseconds: 10);
  String _statusMessage = "Đang chờ...";

  int _frameCount = 0;
  DateTime? _lastFpsTime;
  Timer? _fpsTimer;
  double _currentFps = 0.0;

  List<PreviewFace>? _previewFaces;
  YuNet? _faceDetector;
  SFace? _faceRecognizer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Nếu không có camera khả dụng nào
    if (widget.cameras.isEmpty) {
      setState(() {
        _statusMessage = "Không tìm thấy camera.";
        _selectedCamera = null;
      });
      return;
    }

    // Chọn camera trước (nếu không có camera trước thì chọn camera đầu tiên)
    _selectedCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    // Khởi tạo controller cho camera đã chọn
    if (_selectedCamera != null) {
      _initializeCamera(_selectedCamera!);
      _initializeFaceDetector();
      _initializeFaceRecognizer();
    }
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    // Nếu đã có controller, hủy bỏ nó trước khi tạo mới
    if (_controller != null) {
      _frameProcessingTimer?.cancel();
      _fpsTimer?.cancel();
      await _controller!.dispose();
      _controller = null;
    }

    // Tạo controller mới với camera đã chọn
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Khởi chạy controller
    _initializeControllerFuture = _controller!
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _statusMessage = "";
          });
          _startPeriodicCapture();
          _startFpsCalculation();
        })
        .catchError((Object e) {
          if (e is CameraException) {
            setState(() => _statusMessage = "Lỗi camera: ${e.description}");
          }
        });
  }

  Future<void> _initializeFaceDetector() async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempFilePath =
        '${tempDir.path}/face_detection_yunet_2023mar.onnx';
    final tempFile = File(tempFilePath);

    final ByteData data = await rootBundle.load(
      "assets/face_detection_yunet_2023mar.onnx",
    );
    final List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await tempFile.writeAsBytes(bytes, flush: true);

    setState(() {
      _faceDetector = YuNet(modelPath: tempFilePath, confThreshold: 0.8);
    });
  }

  Future<void> _initializeFaceRecognizer() async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempFilePath =
        '${tempDir.path}/face_recognition_sface_2021dec.onnx';
    final tempFile = File(tempFilePath);

    final ByteData data = await rootBundle.load(
      "assets/face_recognition_sface_2021dec.onnx",
    );
    final List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await tempFile.writeAsBytes(bytes, flush: true);

    setState(() {
      _faceRecognizer = SFace(tempFilePath);
    });
  }

  void _startPeriodicCapture() {
    _frameProcessingTimer?.cancel();
    _frameProcessingTimer = Timer.periodic(_frameInterval, (timer) async {
      if (!mounted ||
          _controller == null ||
          !_controller!.value.isInitialized ||
          _controller!.value.isTakingPicture ||
          _isProcessingFrame) {
        if (!mounted && timer.isActive) timer.cancel();
        return;
      }

      _isProcessingFrame = true;
      try {
        final XFile imageFile = await _controller!.takePicture();

        if (mounted) {
          _frameCount++;

          final cvImage = cv.imread(imageFile.path);
          final faces = _detectFace(cvImage);

          if (faces != null && faces.rows > 0) {
            final features = _extractFeature(cvImage, faces);

            if (features != null) {
              List<PreviewFace> previewFaces = [];
              List<Attendance> attendances = [];

              final imageWidth = cvImage.width;
              final imageHeight = cvImage.height;
              final previewWidth = _controller!.value.previewSize!.height;
              final previewHeight = _controller!.value.previewSize!.width;

              for (int rowId = 0; rowId < features.length; rowId++) {
                var feature = features[rowId];

                var face = faces.row(rowId);
                var student = await widget.attendanceRepository.find(
                  feature.cast(),
                );

                if (!student.success) {
                  setState(() {
                    _statusMessage = student.message ?? "Lỗi API";
                  });
                }

                final x = face.at<double>(0, 0);
                final y = face.at<double>(0, 1);
                final w = face.at<double>(0, 2);
                final h = face.at<double>(0, 3);

                final previewX = x * previewWidth / imageWidth;
                final previewY = y * previewHeight / imageHeight;
                final previewW = w * previewWidth / imageWidth;
                final previewH = h * previewHeight / imageHeight;

                previewFaces.add(
                  PreviewFace(
                    x: previewX,
                    y: previewY,
                    width: previewW,
                    height: previewH,
                    similarity: student.similarity,
                    student: student.student,
                  ),
                );

                if (student.similarity != null &&
                    student.similarity! >= Config.threshold) {
                  attendances.add(
                    Attendance(
                      student: student.student!,
                      lastAttendanceTime: DateTime.now(),
                    ),
                  );
                }

                face.dispose();
              }

              widget.onAttendancesUpdated(attendances);
              setState(() {
                _previewFaces = previewFaces;
                _statusMessage = "";
              });
            }
          } else {
            setState(() {
              _previewFaces = [];
              _statusMessage = "";
            });
          }

          cvImage.dispose();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _statusMessage = "Lỗi: $e");
        }
      } finally {
        if (mounted) {
          _isProcessingFrame = false;
        }
      }
    });
  }

  cv.Mat? _detectFace(cv.Mat cvImage) {
    if (_faceDetector != null) {
      _faceDetector!.setInputSize((cvImage.width, cvImage.height));
      final faces = _faceDetector!.infer(cvImage);
      return faces;
    }
    return null;
  }

  List<List<num>>? _extractFeature(cv.Mat image, cv.Mat faces) {
    if (_faceRecognizer == null || faces.rows == 0) {
      return null;
    }

    List<List<num>> features = [];
    for (int i = 0; i < faces.rows; ++i) {
      final face = faces.row(i);
      final feature = _faceRecognizer!.infer(image, bbox: face);
      features.add(feature.clone().toList()[0]);
      feature.dispose();
    }

    return features;
  }

  void _startFpsCalculation() {
    _fpsTimer?.cancel(); // Hủy timer cũ nếu có
    _frameCount = 0; // Reset bộ đếm
    _lastFpsTime = DateTime.now(); // Đặt thời điểm bắt đầu

    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      if (_lastFpsTime != null) {
        final difference = now.difference(_lastFpsTime!);
        if (difference.inMilliseconds > 0 && _frameCount > 0) {
          setState(() {
            _currentFps = (_frameCount * 1000.0) / difference.inMilliseconds;
          });
        } else if (_frameCount == 0 && difference.inMilliseconds > 0) {
          setState(() {
            _currentFps = 0.0;
          });
        }
      }

      _frameCount = 0; // Reset bộ đếm cho giây tiếp theo
      _lastFpsTime = now; // Cập nhật thời điểm cuối
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameProcessingTimer?.cancel();
    _fpsTimer?.cancel();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      if (state == AppLifecycleState.resumed &&
          _controller == null &&
          _selectedCamera != null) {
        _initializeCamera(_selectedCamera!);
      }
      return;
    }

    // Xử lý khi ứng dụng chuyển trạng thái
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _frameProcessingTimer?.cancel();
      _fpsTimer?.cancel();
      cameraController.dispose().then((_) {
        if (mounted) _controller = null;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && _selectedCamera != null) {
        _initializeCamera(_selectedCamera!);
      } else if (_controller != null &&
          !_controller!.value.isStreamingImages &&
          !_controller!.value.isTakingPicture) {
        _startPeriodicCapture();
        _startFpsCalculation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (_controller == null || !_controller!.value.isInitialized) {
                return Center(
                  child: Text(
                    _statusMessage.isNotEmpty
                        ? _statusMessage
                        : "Không thể khởi tạo camera.",
                  ),
                );
              }

              return FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: Stack(
                    children: [
                      CameraPreview(_controller!),
                      CustomPaint(
                        painter: DetectedFacePainted(
                          previewFaces: _previewFaces ?? [],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        const SizedBox(height: 10),
        Text(
          "FPS: ${_currentFps.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
        if (_statusMessage != "")
          Text(
            _statusMessage,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
      ],
    );
  }
}
