import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints animated rounded viewfinder corner brackets around the brand emblem.
class ViewfinderBracketsPainter extends CustomPainter {
  const ViewfinderBracketsPainter({
    required this.bracketColor,
    required this.bracketProgress,
    required this.innerSize,
  });

  final Color bracketColor;
  final double bracketProgress;
  final double innerSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (bracketProgress <= 0.01) return;

    final insetExpand = (1.0 - bracketProgress) * 14.0;
    final boxSide = innerSize + 18.0 + insetExpand;
    final left = (size.width - boxSide) / 2;
    final top = (size.height - boxSide) / 2;
    final rect = Rect.fromLTWH(left, top, boxSide, boxSide);

    const cornerLen = 18.0;
    final strokePaint = Paint()
      ..color = bracketColor.withValues(alpha: 0.85 * bracketProgress)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(rect.left, rect.top + cornerLen)
      ..lineTo(rect.left, rect.top + 6)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + 6, rect.top)
      ..lineTo(rect.left + cornerLen, rect.top)
      ..moveTo(rect.right - cornerLen, rect.top)
      ..lineTo(rect.right - 6, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 6)
      ..lineTo(rect.right, rect.top + cornerLen)
      ..moveTo(rect.right, rect.bottom - cornerLen)
      ..lineTo(rect.right, rect.bottom - 6)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - 6, rect.bottom)
      ..lineTo(rect.right - cornerLen, rect.bottom)
      ..moveTo(rect.left + cornerLen, rect.bottom)
      ..lineTo(rect.left + 6, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - 6)
      ..lineTo(rect.left, rect.bottom - cornerLen);

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(ViewfinderBracketsPainter oldDelegate) {
    return oldDelegate.bracketProgress != bracketProgress ||
        oldDelegate.bracketColor != bracketColor;
  }
}

/// Paints a smooth vertical optical scan beam inside the FruitLens squircle icon.
class InnerSweepBeamPainter extends CustomPainter {
  const InnerSweepBeamPainter({
    required this.scanProgress,
    required this.beamColor,
    required this.glowColor,
  });

  final double scanProgress;
  final Color beamColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Ping-pong sweep once down and back up smoothly.
    final wave = 0.5 - 0.5 * math.cos(scanProgress * 2 * math.pi);
    final y = size.height * (0.14 + 0.72 * wave);

    final beamBand = Rect.fromLTWH(0, y - 26, size.width, 52);
    final bandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          glowColor.withValues(alpha: 0.0),
          beamColor.withValues(alpha: 0.48),
          glowColor.withValues(alpha: 0.0),
        ],
      ).createShader(beamBand);
    canvas.drawRect(beamBand, bandPaint);

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white,
          beamColor,
          Colors.white.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4))
      ..strokeWidth = 3.2;
    canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), linePaint);
  }

  @override
  bool shouldRepaint(InnerSweepBeamPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}
