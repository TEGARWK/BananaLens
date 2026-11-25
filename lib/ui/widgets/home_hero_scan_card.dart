import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'industrial_art.dart';

/// Flat Editorial Hero Scan Card in Ripe Banana Gold + Roasted Cocoa Brown,
/// accented with 3 gently floating outlined bananas (no background box, non-clickable).
class HomeHeroScanCard extends StatefulWidget {
  const HomeHeroScanCard({
    super.key,
    required this.onScanTap,
    required this.onGalleryTap,
    this.isBusy = false,
  });

  final VoidCallback onScanTap;
  final VoidCallback onGalleryTap;
  final bool isBusy;

  @override
  State<HomeHeroScanCard> createState() => _HomeHeroScanCardState();
}

class _HomeHeroScanCardState extends State<HomeHeroScanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  bool _started = false;

  static bool get _isTestEnvironment => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
      value: 0.25,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!reduceMotion && !_isTestEnvironment) {
      _floatController.repeat();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.primary;
    final textInk = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;
    final cocoaAccent = isDark ? theme.colorScheme.primary : harvest.accent;
    final onCocoaAccent = isDark
        ? theme.colorScheme.onPrimary
        : harvest.onAccent;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppDimens.rHero),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        foregroundPainter: ScannerCornerPainter(
          color: cocoaAccent.withValues(alpha: isDark ? 0.6 : 0.72),
          bracketLength: 14,
          strokeWidth: 2.0,
          inset: 7,
          style: ScannerCornerStyle.diagonal2,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s8 + 2,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cocoaAccent,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rSharp,
                            ),
                          ),
                          child: Text(
                            'DETEKSI INSTAN // AI',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: onCocoaAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.s12),
                        Text(
                          'Pindai Pisang',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: textInk,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: AppDimens.s4),
                        Text(
                          'Ketahui tingkat kematangan pisang dan temukan rekomendasi olahan yang cocok.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textInk.withValues(alpha: 0.82),
                            height: 1.38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  IgnorePointer(
                    child: _FloatingBananasCluster(
                      animation: _floatController,
                      isDark: isDark,
                      strokeColor: isDark
                          ? theme.colorScheme.primary
                          : AppColors.lText,
                      cocoaColor: harvest.accent,
                      primaryYellow: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s16),
              Row(
                children: [
                  Material(
                    color: cocoaAccent,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    child: InkWell(
                      onTap: widget.isBusy ? null : widget.onScanTap,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.center_focus_weak_rounded,
                              color: onCocoaAccent,
                              size: 18,
                            ),
                            const SizedBox(width: AppDimens.s8),
                            Text(
                              'Scan Pisang',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: onCocoaAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Material(
                    color: isDark
                        ? harvest.primarySoft
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    child: InkWell(
                      onTap: widget.isBusy ? null : widget.onGalleryTap,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isBusy)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textInk,
                                ),
                              )
                            else
                              Icon(
                                Icons.photo_library_outlined,
                                color: textInk,
                                size: 18,
                              ),
                            const SizedBox(width: AppDimens.s4 + 2),
                            Text(
                              widget.isBusy ? 'Memproses...' : 'Buka Galeri',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: textInk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative cluster of 3 outlined bananas gently floating with staggered
/// vertical bobbing and rotation — no container box, non-interactive.
class _FloatingBananasCluster extends StatelessWidget {
  const _FloatingBananasCluster({
    required this.animation,
    required this.isDark,
    required this.strokeColor,
    required this.cocoaColor,
    required this.primaryYellow,
  });

  final Animation<double> animation;
  final bool isDark;
  final Color strokeColor;
  final Color cocoaColor;
  final Color primaryYellow;

  @override
  Widget build(BuildContext context) {
    final mainFill = isDark ? primaryYellow : AppColors.lSurface;
    final secondaryFill = isDark ? AppColors.dText : AppColors.lPrimarySoft;
    final accentFill = isDark ? AppColors.dPrimarySoft : cocoaColor;

    return RepaintBoundary(
      child: SizedBox(
        width: 98,
        height: 98,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final angle = animation.value * 2 * math.pi;

            final dy1 = math.sin(angle) * 5.0;
            final rot1 = -0.14 + math.cos(angle) * 0.06;

            final dy2 = math.sin(angle + 2.1) * 4.5;
            final rot2 = 0.24 + math.sin(angle + 1.2) * 0.07;

            final dy3 = math.sin(angle + 4.2) * 4.0;
            final rot3 = -0.36 + math.cos(angle + 2.4) * 0.06;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 4,
                  top: 4 + dy3,
                  child: Transform.rotate(
                    angle: rot3,
                    child: CustomPaint(
                      size: const Size.square(36),
                      painter: _OutlinedBananaPainter(
                        fillColor: accentFill,
                        strokeColor: strokeColor,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 6 + dy2,
                  child: Transform.rotate(
                    angle: rot2,
                    child: CustomPaint(
                      size: const Size.square(44),
                      painter: _OutlinedBananaPainter(
                        fillColor: secondaryFill,
                        strokeColor: strokeColor,
                        strokeWidth: 2.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 20 + dy1,
                  child: Transform.rotate(
                    angle: rot1,
                    child: CustomPaint(
                      size: const Size.square(56),
                      painter: _OutlinedBananaPainter(
                        fillColor: mainFill,
                        strokeColor: strokeColor,
                        strokeWidth: 2.3,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OutlinedBananaPainter extends CustomPainter {
  const _OutlinedBananaPainter({
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.2,
  });

  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

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

    canvas.drawPath(
      bananaPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      bananaPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final ridgePath = Path()
      ..moveTo(w * 0.67, h * 0.34)
      ..quadraticBezierTo(w * 0.59, h * 0.61, w * 0.28, h * 0.73);
    canvas.drawPath(
      ridgePath,
      Paint()
        ..color = strokeColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.65
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_OutlinedBananaPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
