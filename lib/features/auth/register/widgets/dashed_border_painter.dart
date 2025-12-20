import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dashPattern = [dashLength, dashSpace];

    // Top border
    _drawDashedLine(
      canvas,
      Offset(0, 0),
      Offset(size.width, 0),
      paint,
      dashPattern,
    );

    // Right border
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
      dashPattern,
    );

    // Bottom border
    _drawDashedLine(
      canvas,
      Offset(size.width, size.height),
      Offset(0, size.height),
      paint,
      dashPattern,
    );

    // Left border
    _drawDashedLine(
      canvas,
      Offset(0, size.height),
      Offset(0, 0),
      paint,
      dashPattern,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashPattern,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final distance = (end - start).distance;
    final dashLength = dashPattern[0];
    final dashSpace = dashPattern[1];
    final totalDashLength = dashLength + dashSpace;

    double currentDistance = 0;
    while (currentDistance < distance) {
      final t = currentDistance / distance;
      final currentPoint = Offset.lerp(start, end, t)!;
      final nextT = (currentDistance + dashLength) / distance;
      if (nextT > 1) {
        final nextPoint = end;
        path.lineTo(nextPoint.dx, nextPoint.dy);
        break;
      }
      final nextPoint = Offset.lerp(start, end, nextT)!;
      path.moveTo(currentPoint.dx, currentPoint.dy);
      path.lineTo(nextPoint.dx, nextPoint.dy);
      currentDistance += totalDashLength;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

