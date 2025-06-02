import 'package:flutter/material.dart';
import 'package:thesis_app/core/config.dart';
import 'package:thesis_app/core/entities/preview_face.dart';

class DetectedFacePainted extends CustomPainter {
  final List<PreviewFace>? previewFaces;

  DetectedFacePainted({required this.previewFaces});

  @override
  void paint(Canvas canvas, Size size) {
    if (previewFaces == null || previewFaces!.isEmpty) {
      return;
    }

    final paint =
        Paint()
          ..strokeWidth = 3.0
          ..color = Colors.red
          ..style = PaintingStyle.stroke;

    for (final face in previewFaces!) {
      if (face.similarity != null &&
          face.student != null &&
          face.similarity! >= Config.threshold) {
        paint.color = Colors.green;

        final textSpan = TextSpan(
          text: '${face.student?.fullname} - ${face.student?.id}',
          style: TextStyle(color: Colors.green, fontSize: 16.0),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final offset = Offset(face.x, face.y - textPainter.height);
        textPainter.paint(canvas, offset);
      } else {
        paint.color = Colors.red;
        final textSpan = TextSpan(
          text: '${face.similarity?.toStringAsPrecision(3)}',
          style: TextStyle(color: Colors.red, fontSize: 16.0),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final offset = Offset(face.x, face.y - textPainter.height);
        textPainter.paint(canvas, offset);
      }

      canvas.drawRect(
        Rect.fromLTWH(face.x, face.y, face.width, face.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DetectedFacePainted oldDelegate) {
    return oldDelegate.previewFaces != previewFaces;
  }
}
