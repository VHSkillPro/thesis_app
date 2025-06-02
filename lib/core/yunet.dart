import 'package:opencv_dart/opencv_dart.dart';

class YuNet {
  late FaceDetectorYN _model;
  late (int, int) _inputSize = (320, 320);

  YuNet({
    required modelPath,
    (int, int) inputSize = (320, 320),
    double confThreshold = 0.6,
    double nmsThreshold = 0.3,
    int topK = 5000,
  }) {
    _inputSize = _inputSize;
    _model = FaceDetectorYN.fromFile(
      modelPath,
      "",
      inputSize,
      scoreThreshold: confThreshold,
      nmsThreshold: nmsThreshold,
      topK: topK,
    );
  }

  void setInputSize((int, int) inputSize) {
    _inputSize = inputSize;
    _model.setInputSize(inputSize);
  }

  Mat infer(Mat image) {
    final faces = _model.detect(image);
    return faces;
  }

  (int, int) get inputSize => _inputSize;
}
