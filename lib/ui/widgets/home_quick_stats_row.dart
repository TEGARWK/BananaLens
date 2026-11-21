import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/scan_result.dart';
import 'industrial_art.dart';

/// Unified 3-column scan summary strip for BananaLens:
/// `Total Pindai` | `Siap Santap` (ripe + overripe) | `Mentah` (unripe).
/// Uses a single card with concise labels so text never truncates with `...`.
class HomeQuickStatsRow extends StatelessWidget {
  const HomeQuickStatsRow({super.key, required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    final items = historyAsync.asData?.value ?? <ScanResult>[];
    final totalScan = items.length;
    final readyCount = items
        .where(
          (e) =>
              e.ripenessLabel == 'ripe' ||
              e.ripenessLabel == 'overripe' ||
              e.ripenessLabel == 'very_ripe',
        )
        .length;
    final unripeCount = items.where((e) => e.ripenessLabel == 'unripe').length;

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _MetricCell(
                value: '$totalScan',
                label: 'Total Pindai',
                dotColor: theme.colorScheme.primary,
                theme: theme,
                harvest: harvest,
                ink: ink,
              ),
            ),
            VerticalDivider(
              width: AppDimens.s16,
              thickness: 1,
              color: ink.withValues(alpha: 0.16),
            ),
            Expanded(
              child: _MetricCell(
                value: '$readyCount',
                label: 'Siap Santap',
                dotColor: harvest.ripe,
                theme: theme,
                harvest: harvest,
                ink: ink,
              ),
            ),
            VerticalDivider(
              width: AppDimens.s16,
              thickness: 1,
              color: ink.withValues(alpha: 0.16),
            ),
            Expanded(
              child: _MetricCell(
                value: '$unripeCount',
                label: 'Mentah',
                dotColor: harvest.unripe,
                theme: theme,
                harvest: harvest,
                ink: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    required this.dotColor,
    required this.theme,
    required this.harvest,
    required this.ink,
  });

  final String value;
  final String label;
  final Color dotColor;
  final ThemeData theme;
  final HarvestColors harvest;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: 1),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                height: 1.1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: harvest.muted,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
