import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Controls how many scanner viewfinder L-brackets are drawn on a container
/// so layouts stay natural and varied instead of repeating 4 corners everywhere.
enum ScannerCornerStyle {
  /// No corner brackets drawn.
  none,

  /// Single top-left corner bracket (`┌`).
  topLeft1,

  /// Single top-right corner bracket (`┐`).
  topRight1,

  /// Diagonal 2-corner pair (`┌` top-left and `┘` bottom-right).
  diagonal2,

  /// Full 4-corner optical viewfinder (`┌ ┐ └ ┘`) for focal scanner elements.
  all4,
}

/// Paints smooth rounded optical scanner L-brackets (`┌ ┐ └ ┘`) in 1, 2, or 4 corners.
class ScannerCornerPainter extends CustomPainter {
  const ScannerCornerPainter({
    required this.color,
    this.bracketLength = 12,
    this.strokeWidth = 1.8,
    this.inset = 0,
    this.cornerRadius = 4.0,
    this.style = ScannerCornerStyle.all4,
  });

  final Color color;
  final double bracketLength;
  final double strokeWidth;
  final double inset;
  final double cornerRadius;
  final ScannerCornerStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == ScannerCornerStyle.none) return;

    final len = math.min(
      bracketLength,
      math.min(size.width, size.height) * 0.35,
    );
    final r = math.min(cornerRadius, len * 0.45);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = inset + strokeWidth / 2;
    final top = inset + strokeWidth / 2;
    final right = size.width - inset - strokeWidth / 2;
    final bottom = size.height - inset - strokeWidth / 2;

    final drawTopLeft =
        style == ScannerCornerStyle.all4 ||
        style == ScannerCornerStyle.diagonal2 ||
        style == ScannerCornerStyle.topLeft1;
    final drawTopRight =
        style == ScannerCornerStyle.all4 ||
        style == ScannerCornerStyle.topRight1;
    final drawBottomLeft = style == ScannerCornerStyle.all4;
    final drawBottomRight =
        style == ScannerCornerStyle.all4 ||
        style == ScannerCornerStyle.diagonal2;

    if (drawTopLeft) {
      canvas.drawPath(
        Path()
          ..moveTo(left, top + len)
          ..lineTo(left, top + r)
          ..quadraticBezierTo(left, top, left + r, top)
          ..lineTo(left + len, top),
        paint,
      );
    }

    if (drawTopRight) {
      canvas.drawPath(
        Path()
          ..moveTo(right - len, top)
          ..lineTo(right - r, top)
          ..quadraticBezierTo(right, top, right, top + r)
          ..lineTo(right, top + len),
        paint,
      );
    }

    if (drawBottomLeft) {
      canvas.drawPath(
        Path()
          ..moveTo(left, bottom - len)
          ..lineTo(left, bottom - r)
          ..quadraticBezierTo(left, bottom, left + r, bottom)
          ..lineTo(left + len, bottom),
        paint,
      );
    }

    if (drawBottomRight) {
      canvas.drawPath(
        Path()
          ..moveTo(right - len, bottom)
          ..lineTo(right - r, bottom)
          ..quadraticBezierTo(right, bottom, right, bottom - r)
          ..lineTo(right, bottom - len),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ScannerCornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.bracketLength != bracketLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.inset != inset ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.style != style;
}

/// Wraps any child widget with crisp optical viewfinder L-brackets.
class ScannerFrame extends StatelessWidget {
  const ScannerFrame({
    required this.child,
    this.bracketLength = 14,
    this.strokeWidth = 2.0,
    this.bracketColor,
    this.padding = const EdgeInsets.all(6),
    this.inset = 0,
    this.style = ScannerCornerStyle.all4,
    super.key,
  });

  final Widget child;
  final double bracketLength;
  final double strokeWidth;
  final Color? bracketColor;
  final EdgeInsetsGeometry padding;
  final double inset;
  final ScannerCornerStyle style;

  @override
  Widget build(BuildContext context) {
    final color = bracketColor ?? context.harvest.accent;
    return CustomPaint(
      foregroundPainter: ScannerCornerPainter(
        color: color,
        bracketLength: bracketLength,
        strokeWidth: strokeWidth,
        inset: inset,
        style: style,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Crisp flat editorial Banana emblem inside a solid Ripe Banana Gold block
/// accented with diagonal 2-corner viewfinder brackets (`┌ ┘`).
class IndustrialBananaMark extends StatelessWidget {
  const IndustrialBananaMark({
    this.size = 44,
    this.showFrame = true,
    this.frameColor,
    super.key,
  });

  final double size;
  final bool showFrame;
  final Color? frameColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yellow = theme.colorScheme.primary;
    final cocoa = theme.colorScheme.onPrimary;
    final bg = frameColor ?? yellow;

    final art = CustomPaint(
      size: Size.square(size * 0.62),
      painter: _BananaMarkPainter(
        inkColor: cocoa,
        fillColor: showFrame ? theme.colorScheme.surface : yellow,
      ),
    );

    if (!showFrame) return art;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
      ),
      child: CustomPaint(
        foregroundPainter: ScannerCornerPainter(
          color: cocoa.withValues(alpha: 0.72),
          bracketLength: math.max(5.0, size * 0.22),
          strokeWidth: math.max(1.2, size * 0.036),
          inset: math.max(2.0, size * 0.07),
          style: ScannerCornerStyle.diagonal2,
        ),
        child: Center(child: art),
      ),
    );
  }
}

class _BananaMarkPainter extends CustomPainter {
  const _BananaMarkPainter({required this.inkColor, required this.fillColor});

  final Color inkColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bananaPath = Path()
      ..moveTo(w * 0.72, h * 0.16)
      ..lineTo(w * 0.78, h * 0.11)
      ..lineTo(w * 0.84, h * 0.16)
      ..lineTo(w * 0.79, h * 0.24)
      ..cubicTo(w * 0.86, h * 0.56, w * 0.62, h * 0.86, w * 0.18, h * 0.80)
      ..cubicTo(w * 0.13, h * 0.79, w * 0.12, h * 0.72, w * 0.17, h * 0.69)
      ..cubicTo(w * 0.48, h * 0.69, w * 0.68, h * 0.48, w * 0.67, h * 0.24)
      ..close();

    final fillPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bananaPath, fillPaint);

    final ridgePath = Path()
      ..moveTo(w * 0.68, h * 0.34)
      ..quadraticBezierTo(w * 0.60, h * 0.62, w * 0.28, h * 0.73);
    final ridgePaint = Paint()
      ..color = fillColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, w * 0.045)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ridgePath, ridgePaint);
  }

  @override
  bool shouldRepaint(_BananaMarkPainter oldDelegate) =>
      oldDelegate.inkColor != inkColor || oldDelegate.fillColor != fillColor;
}

/// Crisp flat editorial card with configurable 1, 2, or 4 scanner L-brackets
/// (defaults to natural 2-corner diagonal `┌ ┘`) and subtle 1px warm hairline.
class IndustrialSpecimenCard extends StatelessWidget {
  const IndustrialSpecimenCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.s16),
    this.backgroundColor,
    this.showScanCorners = true,
    this.cornerStyle = ScannerCornerStyle.diagonal2,
    this.cornerColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showScanCorners;
  final ScannerCornerStyle cornerStyle;
  final Color? cornerColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final bg = backgroundColor != null
        ? Color.alphaBlend(backgroundColor!, theme.colorScheme.surface)
        : theme.colorScheme.surface;
    final reticleColor = cornerColor ?? harvest.accent.withValues(alpha: 0.45);
    final effectiveStyle = showScanCorners
        ? cornerStyle
        : ScannerCornerStyle.none;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: harvest.border, width: 1),
      ),
      child: effectiveStyle != ScannerCornerStyle.none
          ? CustomPaint(
              foregroundPainter: ScannerCornerPainter(
                color: reticleColor,
                bracketLength: 11,
                strokeWidth: 1.6,
                inset: 5,
                style: effectiveStyle,
              ),
              child: Padding(padding: padding, child: child),
            )
          : Padding(padding: padding, child: child),
    );
  }
}

/// Flat borderless editorial tag chip using Roasted Cocoa Brown or Soft Oat
/// color-blocking — zero stroke, zero hard shadow.
class IndustrialTagChip extends StatelessWidget {
  const IndustrialTagChip({
    required this.label,
    this.accent = false,
    super.key,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8 + 2,
        vertical: AppDimens.s4 + 1,
      ),
      decoration: BoxDecoration(
        color: accent ? harvest.accent : harvest.primarySoft,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent ? harvest.onAccent : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

/// Precision 48-tick radial dial painter for splash/scanner instrument accents.
class RadialDialTicksPainter extends CustomPainter {
  const RadialDialTicksPainter({
    required this.tickColor,
    required this.accentColor,
    this.progress = 1.0,
  });

  final Color tickColor;
  final Color accentColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    const totalTicks = 48;

    for (int i = 0; i < totalTicks; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / totalTicks);
      final isMajor = i % 4 == 0;
      final tickLen = isMajor ? 10.0 : 5.0;
      final isActive = (i / totalTicks) <= progress;

      final paint = Paint()
        ..color = isActive && isMajor
            ? accentColor
            : tickColor.withValues(alpha: isMajor ? 0.5 : 0.24)
        ..strokeWidth = isMajor ? 1.5 : 1.0
        ..strokeCap = StrokeCap.butt;

      final p1 = Offset(
        center.dx + (outerRadius - tickLen) * math.cos(angle),
        center.dy + (outerRadius - tickLen) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(RadialDialTicksPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.tickColor != tickColor ||
      oldDelegate.accentColor != accentColor;
}
