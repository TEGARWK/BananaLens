import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import 'fruit_image.dart';
import 'industrial_art.dart';
import 'ripeness_chip.dart';

/// Hero specimen card displaying the scanned photo, timestamp, ripeness, and accuracy.
class HistoryDetailHeroCard extends StatelessWidget {
  const HistoryDetailHeroCard({
    super.key,
    required this.item,
    required this.fruitTitle,
    required this.formattedDate,
    required this.ripeness,
    required this.onOpenFullscreen,
    required this.onShowBreakdown,
  });

  final ScanResult item;
  final String fruitTitle;
  final String formattedDate;
  final Ripeness? ripeness;
  final VoidCallback onOpenFullscreen;
  final VoidCallback onShowBreakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final confPct = (item.confidence * 100).round();
    final (accBg, accFg) = _accuracyColors(ripeness, theme);

    return IndustrialSpecimenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IndustrialTagChip(label: 'CATATAN · PINDAI', accent: true),
              const SizedBox(width: AppDimens.s8),
              Expanded(
                child: Text(
                  formattedDate,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          _HeroPhotoBox(
            imagePath: item.imagePath,
            fruitLabel: item.fruitLabel,
            onOpenFullscreen: onOpenFullscreen,
          ),
          const SizedBox(height: AppDimens.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fruitTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    if (ripeness != null) RipenessChip(ripeness: ripeness!),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              _ConfidenceTapBox(
                confPct: confPct,
                bgColor: accBg,
                fgColor: accFg,
                onTap: onShowBreakdown,
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _accuracyColors(Ripeness? value, ThemeData theme) {
    return switch (value) {
      Ripeness.rotten => (AppColors.lError, Colors.white),
      Ripeness.unripe => (AppColors.lLeafStrong, Colors.white),
      Ripeness.overripe => (const Color(0xFFD97706), Colors.white),
      Ripeness.ripe ||
      null => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
    };
  }
}

class _HeroPhotoBox extends StatelessWidget {
  const _HeroPhotoBox({
    required this.imagePath,
    required this.fruitLabel,
    required this.onOpenFullscreen,
  });

  final String imagePath;
  final String fruitLabel;
  final VoidCallback onOpenFullscreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Stack(
      children: [
        GestureDetector(
          onTap: onOpenFullscreen,
          child: Container(
            width: double.infinity,
            height: 204,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              border: Border.all(color: harvest.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.rButton - 1),
              child: FruitImage(
                imagePath: imagePath,
                fruitLabel: fruitLabel,
                height: 204,
                fit: BoxFit.cover,
                radius: 0,
              ),
            ),
          ),
        ),
        Positioned(
          right: AppDimens.s8,
          bottom: AppDimens.s8,
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            child: InkWell(
              onTap: onOpenFullscreen,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8 + 2,
                  vertical: AppDimens.s4 + 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: harvest.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen_rounded, size: 15, color: ink),
                    const SizedBox(width: AppDimens.s4),
                    Text(
                      'Perbesar',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfidenceTapBox extends StatelessWidget {
  const _ConfidenceTapBox({
    required this.confPct,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  final int confPct;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Ketuk untuk lihat rincian skor AI',
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$confPct%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: AppDimens.s4),
                    Icon(Icons.bar_chart_rounded, size: 16, color: fgColor),
                  ],
                ),
                Text(
                  'Akurasi Kematangan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fgColor.withValues(alpha: 0.9),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ketuk untuk rincian',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fgColor.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
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
