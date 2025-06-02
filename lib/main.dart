import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path_provider/path_provider.dart';
import 'package:thesis_app/core/sface_custom.dart';
import 'package:thesis_app/core/yunet.dart';
import 'package:thesis_app/screens/attendance_screen.dart';

late List<CameraDescription> _cameras;

Future<String> loadAssetToTempFile(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final Uint8List bytes = byteData.buffer.asUint8List();

  final fileName = path.basename(assetPath);
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/$fileName');

  await tempFile.writeAsBytes(bytes);
  return tempFile.path;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // evaluate();
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
    _cameras = [];
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AttendanceScreen(cameras: _cameras),
    );
  }
}

void evaluate() async {
  List<String> images = [
    "assets/selfies_3/21T1020820_HoVietTung/vlcsnap-2024122500006.png",
    "assets/selfies_3/21T1020820_HoVietTung/vlcsnap-2024122500005.png",
    "assets/selfies_3/21T1020820_HoVietTung/vlcsnap-2024122500004.png",
    "assets/selfies_3/21T1020820_HoVietTung/vlcsnap-2024122500002.png",
    "assets/selfies_3/21T1020820_HoVietTung/vlcsnap-2024122500001.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-00062.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-00061.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-2024122500087.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-2024122500086.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-2024122500088.png",
    "assets/selfies_3/24T1020459_TranDangNhatThanh/vlcsnap-2024122500085.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-2024122500029.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-00017.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-00016.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-00018.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-2024122500028.png",
    "assets/selfies_3/24T1020202_NguyenQuangHuy/vlcsnap-00015.png",
    "assets/selfies_3/24T1020557_NguyenThanhVu/vlcsnap-2024122500095.png",
    "assets/selfies_3/24T1020557_NguyenThanhVu/vlcsnap-2024122500096.png",
    "assets/selfies_3/24T1020519_LeAnhTu/vlcsnap-2024122500138.png",
    "assets/selfies_3/24T1020519_LeAnhTu/vlcsnap-2024122500137.png",
    "assets/selfies_3/24T1020519_LeAnhTu/vlcsnap-2024122500136.png",
    "assets/selfies_3/24T1020519_LeAnhTu/vlcsnap-2024122500139.png",
    "assets/selfies_3/21T1020372_NguyenDinhThaiHoa/Hoa_NguyenDinhThai_21T1020372_ChanDung.jpg",
    "assets/selfies_3/21T1020372_NguyenDinhThaiHoa/vlcsnap-2024122500023.png",
    "assets/selfies_3/21T1020372_NguyenDinhThaiHoa/vlcsnap-2024122500028.png",
    "assets/selfies_3/21T1020372_NguyenDinhThaiHoa/vlcsnap-2024122500036.png",
    "assets/selfies_3/21T1020372_NguyenDinhThaiHoa/vlcsnap-2024122500030.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-00098.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-00001.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-00097.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-2024122500128.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-2024122500126.png",
    "assets/selfies_3/24T1020526_PhanCongTuan/vlcsnap-2024122500129.png",
    "assets/selfies_3/24T1020271_LeTanTranLong/vlcsnap-00033.png",
    "assets/selfies_3/24T1020271_LeTanTranLong/vlcsnap-2024122500047.png",
    "assets/selfies_3/24T1020271_LeTanTranLong/vlcsnap-2024122500045.png",
    "assets/selfies_3/24T1020271_LeTanTranLong/vlcsnap-2024122500046.png",
    "assets/selfies_3/24T1020271_LeTanTranLong/vlcsnap-00032.png",
    "assets/selfies_3/24T1020101_NguyenTrongDung/vlcsnap-2024122500013.png",
    "assets/selfies_3/24T1020101_NguyenTrongDung/vlcsnap-2024122500014.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500157.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500153.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500155.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500154.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500158.png",
    "assets/selfies_3/23T1020175_TranDinhQuangHieu/vlcsnap-2024122500156.png",
    "assets/selfies_3/24T1020034_HaVanBao/vlcsnap-2024122500006.png",
    "assets/selfies_3/24T1020034_HaVanBao/vlcsnap-2024122500005.png",
    "assets/selfies_3/24T1020034_HaVanBao/vlcsnap-2024122500007.png",
    "assets/selfies_3/24T1020383_NguyenKimTheQuan/vlcsnap-2024122500072.png",
    "assets/selfies_3/24T1020383_NguyenKimTheQuan/vlcsnap-2024122500068.png",
    "assets/selfies_3/24T1020383_NguyenKimTheQuan/vlcsnap-2024122500070.png",
    "assets/selfies_3/24T1020383_NguyenKimTheQuan/vlcsnap-2024122500069.png",
    "assets/selfies_3/24T1020383_NguyenKimTheQuan/vlcsnap-2024122500071.png",
    "assets/selfies_3/24T1020435_NgoDacTrungTan/vlcsnap-2024122500070.png",
    "assets/selfies_3/24T1020435_NgoDacTrungTan/vlcsnap-2024122500011.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500034.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500038.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500035.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500039.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500037.png",
    "assets/selfies_3/21T1020759_PhanThanhToan/vlcsnap-2024122500036.png",
  ];

  // Load models
  final yunet = YuNet(
    modelPath: await loadAssetToTempFile(
      "assets/face_detection_yunet_2023mar.onnx",
    ),
  );
  final sfaceCustom = SFaceCustom("assets/sface-baseline-casia.onnx");
  await sfaceCustom.initialize();

  // Evaluate each image
  List<int> latencies = [];

  for (int i = 0; i < 3; ++i) {
    String imagePath = images[i];
    final image = cv.imread(await loadAssetToTempFile(imagePath));
    yunet.setInputSize((image.width, image.height));
    final faces = yunet.infer(image);

    final sw = Stopwatch()..start();
    await sfaceCustom.infer(image, bbox: faces.row(0));
    sw.stop();
  }

  for (int j = 0; j < 3; ++j) {
    for (int i = 0; i < images.length; ++i) {
      String imagePath = images[i];
      final image = cv.imread(await loadAssetToTempFile(imagePath));
      yunet.setInputSize((image.width, image.height));
      final faces = yunet.infer(image);

      final sw = Stopwatch()..start();
      await sfaceCustom.infer(image, bbox: faces.row(0));
      sw.stop();

      latencies.add(sw.elapsedMilliseconds);
      print("$i / ${images.length} - Latency: ${sw.elapsedMilliseconds} ms");
    }
  }

  // Print the results
  final totalLatency = latencies.reduce((a, b) => a + b);
  final averageLatency = totalLatency / latencies.length;
  print("Total Latency: $totalLatency ms");
  print("Average Latency: $averageLatency ms");

  print(latencies);
}
