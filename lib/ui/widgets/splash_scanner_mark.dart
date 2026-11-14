import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'splash_scanner_painters.dart';

/// Animated FruitLens brand emblem with concentric halo pulses, viewfinder
/// brackets, and an optical AI scan sweep.
class SplashScannerMark extends StatelessWidget {
  const SplashScannerMark({required this.progress, this.size = 124, super.key});

  /// Normalized animation timeline in `[0.0, 1.0]`.
  final double progress;

  /// Width and height of the inner squircle icon badge.
  final double size;

  static const String _brandIconAsset = 'assets/images/brand/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final t = progress.clamp(0.0, 1.0);

    // Pop-in spring for the core emblem (0.00 -> 0.25).
    final entryT = const Interval(
      0.0,
      0.25,
      curve: Curves.easeOutBack,
    ).transform(t);
    final iconScale = 0.70 + (0.30 * entryT);
    final iconOpacity = const Interval(
      0.0,
      0.16,
      curve: Curves.easeOut,
    ).transform(t);

    // Bracket tighten and prolonged scan sweep timing (0.08 -> 0.76);
    // 0.85 -> 1.00 acts as a crisp settle hold at full state.
    final bracketT = const Interval(
      0.08,
      0.32,
      curve: Curves.easeOutCubic,
    ).transform(t);
    final scanWindow = const Interval(0.16, 0.76).transform(t);
    final scanActive = t >= 0.16 && t <= 0.76;

    // Gentle expanding ambient ripple during active scan.
    final rippleT = const Interval(
      0.12,
      0.82,
      curve: Curves.easeOut,
    ).transform(t);
    final rippleOpacity = (1.0 - rippleT).clamp(0.0, 1.0) * 0.32;
    final containerExtent = size + 38;

    return Semantics(
      label: AppStrings.splashSemantics,
      image: true,
      child: SizedBox(
        width: containerExtent,
        height: containerExtent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (rippleOpacity > 0.01)
              _AmbientHaloRing(
                size: size + 24,
                scale: 0.92 + (rippleT * 0.42),
                opacity: rippleOpacity,
              ),
            CustomPaint(
              size: Size.square(containerExtent),
              painter: ViewfinderBracketsPainter(
                bracketColor: theme.colorScheme.primary,
                bracketProgress: bracketT,
                innerSize: size,
              ),
            ),
            _SquircleIconCard(
              size: size,
              opacity: iconOpacity.clamp(0.0, 1.0),
              scale: iconScale,
              scanActive: scanActive,
              scanWindow: scanWindow,
              brandIconAsset: _brandIconAsset,
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              accent: harvest.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientHaloRing extends StatelessWidget {
  const _AmbientHaloRing({
    required this.size,
    required this.scale,
    required this.opacity,
  });

  final double size;
  final double scale;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: opacity),
            width: 2,
          ),
          color: harvest.primarySoft.withValues(alpha: opacity * 0.65),
        ),
      ),
    );
  }
}

class _SquircleIconCard extends StatelessWidget {
  const _SquircleIconCard({
    required this.size,
    required this.opacity,
    required this.scale,
    required this.scanActive,
    required this.scanWindow,
    required this.brandIconAsset,
    required this.primary,
    required this.onPrimary,
    required this.accent,
  });

  final double size;
  final double opacity;
  final double scale;
  final bool scanActive;
  final double scanWindow;
  final String brandIconAsset;
  final Color primary;
  final Color onPrimary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rSheet),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.rSheet),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  brandIconAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: primary,
                    child: Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: size * 0.56,
                        color: onPrimary,
                      ),
                    ),
                  ),
                ),
                if (scanActive)
                  CustomPaint(
                    painter: InnerSweepBeamPainter(
                      scanProgress: scanWindow,
                      beamColor: accent,
                      glowColor: primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
