import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'industrial_art.dart';
import 'splash_scanner_painters.dart';

/// Animated BananaLens brand emblem with precision radial dial ticks,
/// viewfinder brackets, and an optical yellow scan sweep.
class SplashScannerMark extends StatelessWidget {
  const SplashScannerMark({required this.progress, this.size = 124, super.key});

  /// Normalized animation timeline in `[0.0, 1.0]`.
  final double progress;

  /// Width and height of the inner instrument emblem box.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final t = progress.clamp(0.0, 1.0);
    final ink = theme.colorScheme.onSurface;
    final yellow = theme.colorScheme.primary;

    // Pop-in spring for the core emblem (0.00 -> 0.25).
    final entryT = const Interval(
      0.0,
      0.25,
      curve: Curves.easeOutBack,
    ).transform(t);
    final iconScale = 0.72 + (0.28 * entryT);
    final iconOpacity = const Interval(
      0.0,
      0.16,
      curve: Curves.easeOut,
    ).transform(t);

    final bracketT = const Interval(
      0.08,
      0.32,
      curve: Curves.easeOutCubic,
    ).transform(t);
    final scanWindow = const Interval(0.16, 0.76).transform(t);
    final scanActive = t >= 0.16 && t <= 0.76;
    final containerExtent = size + 56;

    return Semantics(
      label: AppStrings.splashSemantics,
      image: true,
      child: SizedBox(
        width: containerExtent,
        height: containerExtent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(containerExtent),
              painter: RadialDialTicksPainter(
                tickColor: harvest.muted,
                accentColor: yellow,
                progress: t,
              ),
            ),
            CustomPaint(
              size: Size.square(size + 30),
              painter: ViewfinderBracketsPainter(
                bracketColor: ink,
                bracketProgress: bracketT,
                innerSize: size,
              ),
            ),
            _InstrumentEmblemCard(
              size: size,
              opacity: iconOpacity.clamp(0.0, 1.0),
              scale: iconScale,
              scanActive: scanActive,
              scanWindow: scanWindow,
              primary: yellow,
              ink: ink,
              surface: theme.colorScheme.surface,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstrumentEmblemCard extends StatelessWidget {
  const _InstrumentEmblemCard({
    required this.size,
    required this.opacity,
    required this.scale,
    required this.scanActive,
    required this.scanWindow,
    required this.primary,
    required this.ink,
    required this.surface,
  });

  final double size;
  final double opacity;
  final double scale;
  final bool scanActive;
  final double scanWindow;
  final Color primary;
  final Color ink;
  final Color surface;

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
            color: surface,
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            border: Border.all(color: ink, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: ink.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.rCard - 1),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: IndustrialBananaMark(
                    size: size * 0.84,
                    showFrame: false,
                  ),
                ),
                if (scanActive)
                  CustomPaint(
                    painter: InnerSweepBeamPainter(
                      scanProgress: scanWindow,
                      beamColor: primary,
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
