import 'package:flutter/material.dart';

class QrScannerOverlay extends StatelessWidget {
  const QrScannerOverlay({super.key, this.borderColor = Colors.white});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cutOutSize = constraints.maxWidth * 0.7;
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScannerOverlayPainter(
            cutOutSize: cutOutSize,
            borderColor: borderColor,
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.cutOutSize,
    required this.borderColor,
  });

  final double cutOutSize;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, const Radius.circular(16)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutOutPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withAlpha(140),
    );

    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    final r = cutOutRect;

    void drawCorner(Offset start, Offset h, Offset v) {
      canvas.drawLine(start, start + h, cornerPaint);
      canvas.drawLine(start, start + v, cornerPaint);
    }

    drawCorner(r.topLeft, const Offset(cornerLength, 0), const Offset(0, cornerLength));
    drawCorner(r.topRight, const Offset(-cornerLength, 0), const Offset(0, cornerLength));
    drawCorner(r.bottomLeft, const Offset(cornerLength, 0), const Offset(0, -cornerLength));
    drawCorner(r.bottomRight, const Offset(-cornerLength, 0), const Offset(0, -cornerLength));
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutOutSize != cutOutSize ||
        oldDelegate.borderColor != borderColor;
  }
}
