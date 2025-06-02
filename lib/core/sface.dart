import 'package:opencv_dart/opencv_dart.dart';

class SFace {
  late FaceRecognizerSF _model;

  SFace(String modelPath) {
    _model = FaceRecognizerSF.fromFile(modelPath, "");
  }

  Mat _preprocess(Mat image, Mat? bbox) {
    if (bbox == null) {
      return image;
    }
    return _model.alignCrop(image, bbox);
  }

  Mat infer(Mat image, {Mat? bbox}) {
    final inputBlob = _preprocess(image, bbox);
    final features = _model.feature(inputBlob);
    return features;
  }

  double match(Mat image1, Mat face1, Mat image2, Mat face2) {
    final features1 = infer(image1, bbox: face1);
    final features2 = infer(image2, bbox: face2);
    return _model.match(features1, features2);
  }
}
