import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'industrial_art.dart';
import 'splash_scanner_painters.dart';

/// Animated BananaLens brand emblem framed by crisp 4-corner Roasted Cocoa
/// viewfinder brackets (`┌ ┐ └ ┘`) and a smooth optical scan sweep beam.
class SplashScannerMark extends StatelessWidget {
  const SplashScannerMark({required this.progress, this.size = 116, super.key});

  /// Normalized animation timeline in `[0.0, 1.0]`.
  final double progress;

  /// Width and height of the inner emblem block.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final t = progress.clamp(0.0, 1.0);
    final yellow = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final bracketColor = isDark ? yellow : harvest.accent;

    // Pop-in spring for the core emblem (0.00 -> 0.25).
    final entryT = const Interval(
      0.0,
      0.25,
      curve: Curves.easeOutBack,
    ).transform(t);
    final iconScale = 0.78 + (0.22 * entryT);
    final iconOpacity = const Interval(
      0.0,
      0.16,
      curve: Curves.easeOut,
    ).transform(t);

    final bracketT = const Interval(
      0.06,
      0.32,
      curve: Curves.easeOutCubic,
    ).transform(t);
    final scanWindow = const Interval(0.16, 0.78).transform(t);
    final scanActive = t >= 0.16 && t <= 0.78;
    final containerExtent = size + 44;

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
              painter: ViewfinderBracketsPainter(
                bracketColor: bracketColor,
                bracketProgress: bracketT,
                innerSize: size,
              ),
            ),
            _FlatEmblemBlock(
              size: size,
              opacity: iconOpacity.clamp(0.0, 1.0),
              scale: iconScale,
              scanActive: scanActive,
              scanWindow: scanWindow,
              blockColor: yellow,
              beamColor: isDark ? harvest.onAccent : harvest.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatEmblemBlock extends StatelessWidget {
  const _FlatEmblemBlock({
    required this.size,
    required this.opacity,
    required this.scale,
    required this.scanActive,
    required this.scanWindow,
    required this.blockColor,
    required this.beamColor,
  });

  final double size;
  final double opacity;
  final double scale;
  final bool scanActive;
  final double scanWindow;
  final Color blockColor;
  final Color beamColor;

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
            color: blockColor,
            borderRadius: BorderRadius.circular(AppDimens.rHero),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: IndustrialBananaMark(
                  size: size * 0.76,
                  showFrame: false,
                ),
              ),
              if (scanActive)
                CustomPaint(
                  painter: InnerSweepBeamPainter(
                    scanProgress: scanWindow,
                    beamColor: beamColor,
                    glowColor: beamColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
