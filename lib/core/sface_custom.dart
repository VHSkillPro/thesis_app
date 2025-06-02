import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:opencv_dart/opencv_dart.dart';
import 'package:path_provider/path_provider.dart';

class SFaceCustom {
  late String _modelPath;
  late FaceRecognizerSF _model;
  late OrtSession _session;

  SFaceCustom(String modelPath) {
    _modelPath = modelPath;
  }

  Future<void> initializeSFace() async {
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

    _model = FaceRecognizerSF.fromFile(tempFilePath, "");
  }

  Future<void> initializeSFaceCustom(String modelPath) async {
    final ort = OnnxRuntime();
    _session = await ort.createSessionFromAsset(modelPath);
  }

  Future<void> initialize() async {
    await initializeSFace();
    await initializeSFaceCustom(_modelPath);
  }

  Mat _preprocess(Mat image, Mat? bbox) {
    if (bbox == null) {
      return image;
    }
    return _model.alignCrop(image, bbox);
  }

  List<double> _chwDataFromHWC(Uint8List hwcData, int height, int width) {
    final int channels = 3;
    final List<double> chw = List.filled(height * width * channels, 0.0);

    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        for (int c = 0; c < channels; c++) {
          int hwcIndex = (h * width + w) * channels + c; // HWC index
          int chwIndex = c * height * width + h * width + w; // CHW index
          chw[chwIndex] = hwcData[hwcIndex] / 1.0;
        }
      }
    }
    return chw;
  }

  Future<Mat> infer(Mat image, {Mat? bbox}) async {
    final inputBlob = _preprocess(image, bbox);

    final chwInput = _chwDataFromHWC(inputBlob.data, 112, 112);
    final inputTensor = await OrtValue.fromList(chwInput, [1, 3, 112, 112]);
    final result = await _session.run({'data': inputTensor});

    final outputTensor = result['fc1'] as OrtValue;
    return Mat.fromList(
      1,
      128,
      MatType.CV_32FC1,
      (await outputTensor.asFlattenedList()).cast<num>(),
    );
  }

  Future<double> match(Mat image1, Mat face1, Mat image2, Mat face2) async {
    final features1 = await infer(image1, bbox: face1);
    final features2 = await infer(image2, bbox: face2);
    return _model.match(features1, features2);
  }

  void dispose() {
    _model.dispose();
    _session.close();
  }
}
