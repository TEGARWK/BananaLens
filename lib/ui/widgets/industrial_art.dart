import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Technical line-art Banana emblem with yellow accent fill inside a
/// tactile instrument frame (`1.5px` dark ink border).
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
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? theme.colorScheme.onSurface : const Color(0xFF181A16);
    final yellow = theme.colorScheme.primary;
    final bg =
        frameColor ??
        (isDark ? theme.colorScheme.surface : const Color(0xFFF9FAF6));

    final art = CustomPaint(
      size: Size.square(size * 0.64),
      painter: _BananaLineArtPainter(inkColor: ink, accentColor: yellow),
    );

    if (!showFrame) return art;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        border: Border.all(color: ink, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: yellow.withValues(alpha: 0.9),
            offset: const Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.rButton - 3),
          border: Border.all(color: yellow.withValues(alpha: 0.85), width: 1.2),
        ),
        alignment: Alignment.center,
        child: art,
      ),
    );
  }
}

class _BananaLineArtPainter extends CustomPainter {
  const _BananaLineArtPainter({
    required this.inkColor,
    required this.accentColor,
  });

  final Color inkColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stylized technical banana silhouette (crescent + stem + tip).
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
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bananaPath, fillPaint);

    final strokePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, w * 0.055)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bananaPath, strokePaint);

    // Subtle ridge line inside banana for technical line-art feel.
    final ridgePath = Path()
      ..moveTo(w * 0.68, h * 0.34)
      ..quadraticBezierTo(w * 0.60, h * 0.62, w * 0.28, h * 0.73);
    final ridgePaint = Paint()
      ..color = inkColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.032)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ridgePath, ridgePaint);

    // Micro measurement tick marks at top-left.
    final tickPaint = Paint()
      ..color = inkColor.withValues(alpha: 0.55)
      ..strokeWidth = math.max(1.0, w * 0.03);
    canvas.drawLine(
      Offset(w * 0.14, h * 0.18),
      Offset(w * 0.28, h * 0.18),
      tickPaint,
    );
    canvas.drawLine(
      Offset(w * 0.14, h * 0.28),
      Offset(w * 0.22, h * 0.28),
      tickPaint,
    );
  }

  @override
  bool shouldRepaint(_BananaLineArtPainter oldDelegate) =>
      oldDelegate.inkColor != inkColor ||
      oldDelegate.accentColor != accentColor;
}

/// Specimen card with subtle vertical micro-ribbed lines and 1px hairline border.
class IndustrialSpecimenCard extends StatelessWidget {
  const IndustrialSpecimenCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.s16),
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final bg = backgroundColor ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;
    final outerInk = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.7)
        : const Color(0xFF4A4E42);

    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: outerInk, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.65),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.rCard - 1.5),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.75),
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.rCard - 2),
          child: CustomPaint(
            painter: _MicroRibbedPainter(
              lineColor: harvest.border.withValues(alpha: 0.4),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class _MicroRibbedPainter extends CustomPainter {
  const _MicroRibbedPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;
    const step = 7.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_MicroRibbedPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

/// Technical uppercase monospace badge with optional yellow accent fill.
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
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? theme.colorScheme.onSurface : const Color(0xFF181A16);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s4 + 2,
      ),
      decoration: BoxDecoration(
        color: accent ? theme.colorScheme.primary : harvest.primarySoft,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: accent ? ink : harvest.muted, width: 1.4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (accent ? ink : harvest.border).withValues(alpha: 0.85),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent ? theme.colorScheme.onPrimary : ink,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Precision 60-tick radial dial painter for instrument backgrounds.
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
            : tickColor.withValues(alpha: isMajor ? 0.55 : 0.28)
        ..strokeWidth = isMajor ? 1.6 : 1.0
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
