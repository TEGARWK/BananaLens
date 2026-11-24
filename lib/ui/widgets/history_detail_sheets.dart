import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import 'fruit_image.dart';

/// Opens a fullscreen pinch-to-zoom viewer for a scanned fruit photo.
Future<void> showHistoryFullscreenImage(
  BuildContext context, {
  required String imagePath,
  required String fruitLabel,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.dSurfaceDark.withValues(alpha: 0.92),
    builder: (dialogContext) {
      return Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.s16),
                child: FruitImage(
                  imagePath: imagePath,
                  fruitLabel: fruitLabel,
                  fit: BoxFit.contain,
                  radius: AppDimens.rCard,
                ),
              ),
            ),
          ),
          Positioned(
            top: AppDimens.s16,
            right: AppDimens.s16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                tooltip: 'Tutup',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.dSurfaceDark.withValues(
                    alpha: 0.72,
                  ),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Shows an estimated 4-class ripeness score breakdown for a history record.
Future<void> showHistoryConfidenceBreakdownSheet(
  BuildContext context, {
  required int confPct,
  required Ripeness? ripeness,
}) {
  final theme = Theme.of(context);
  final harvest = context.harvest;
  final ink = theme.colorScheme.onSurface;
  final detected = ripeness ?? Ripeness.ripe;
  final remainder = (100 - confPct).clamp(0, 100);
  final otherClasses = Ripeness.values
      .where((value) => value != detected)
      .toList();
  final baseOther = remainder ~/ otherClasses.length;
  final extra = remainder % otherClasses.length;

  final scores = <Ripeness, int>{detected: confPct};
  for (var i = 0; i < otherClasses.length; i++) {
    scores[otherClasses[i]] = baseOther + (i < extra ? 1 : 0);
  }

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppDimens.s12),
          padding: const EdgeInsets.all(AppDimens.s20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            border: Border.all(color: harvest.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.s8),
                    decoration: BoxDecoration(
                      color: harvest.primarySoft,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                    ),
                    child: Icon(Icons.bar_chart_rounded, size: 18, color: ink),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Text(
                      'Rincian Akurasi Kematangan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                'Estimasi distribusi skor model AI untuk kelas kematangan '
                'pada pemindaian tersimpan ini:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              for (var i = 0; i < Ripeness.values.length; i++) ...[
                if (i > 0) const SizedBox(height: AppDimens.s12),
                _RipenessBreakdownRow(
                  label: Ripeness.values[i].labelId,
                  isDetected: Ripeness.values[i] == detected,
                  fraction: (scores[Ripeness.values[i]] ?? 0) / 100.0,
                  valueText: '${scores[Ripeness.values[i]] ?? 0}%',
                  barColor: _barColorFor(Ripeness.values[i], theme, harvest),
                  badgeFg: Ripeness.values[i] == Ripeness.ripe
                      ? ink
                      : Colors.white,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Color _barColorFor(Ripeness value, ThemeData theme, HarvestColors harvest) {
  return switch (value) {
    Ripeness.unripe => harvest.unripe,
    Ripeness.ripe => theme.colorScheme.primary,
    Ripeness.overripe => harvest.overripe,
    Ripeness.rotten => harvest.rotten,
  };
}

class _RipenessBreakdownRow extends StatelessWidget {
  const _RipenessBreakdownRow({
    required this.label,
    required this.isDetected,
    required this.fraction,
    required this.valueText,
    required this.barColor,
    required this.badgeFg,
  });

  final String label;
  final bool isDetected;
  final double fraction;
  final String valueText;
  final Color barColor;
  final Color badgeFg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isDetected ? FontWeight.w800 : FontWeight.w600,
                    color: isDetected ? ink : harvest.muted,
                  ),
                ),
                if (isDetected) ...[
                  const SizedBox(width: AppDimens.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    ),
                    child: Text(
                      'TERDETEKSI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: badgeFg,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              valueText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDetected ? ink : harvest.muted,
                fontWeight: isDetected ? FontWeight.w800 : FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          child: Container(
            height: 8,
            color: harvest.primarySoft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: ColoredBox(
                  color: barColor,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
