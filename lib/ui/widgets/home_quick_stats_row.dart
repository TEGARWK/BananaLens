import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/scan_result.dart';

/// Joined 2-tone Swiss Editorial KPI Metric Bar for BananaLens:
/// `[ Total Pindai | Siap Santap ][ Mentah ]` — connected color blocks with zero gap.
class HomeQuickStatsRow extends StatelessWidget {
  const HomeQuickStatsRow({super.key, required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;

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

    final charcoalBg = isDark ? theme.colorScheme.surface : harvest.accent;
    final charcoalFg = isDark ? theme.colorScheme.onSurface : harvest.onAccent;
    final charcoalDivider = charcoalFg.withValues(alpha: 0.18);
    final unripeBg = isDark ? harvest.primarySoft : theme.colorScheme.surface;
    final unripeFg = theme.colorScheme.onSurface;
    final yellowBg = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: harvest.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left joined Soft Charcoal block (Total Pindai | Siap Santap)
            Expanded(
              flex: 2,
              child: ColoredBox(
                color: charcoalBg,
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        value: '$totalScan',
                        label: 'Total Pindai',
                        valueColor: isDark ? yellowBg : charcoalFg,
                        labelColor: charcoalFg.withValues(alpha: 0.8),
                        theme: theme,
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: charcoalDivider,
                    ),
                    Expanded(
                      child: _MetricCell(
                        value: '$readyCount',
                        label: 'Siap Santap',
                        valueColor: yellowBg,
                        labelColor: charcoalFg.withValues(alpha: 0.8),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right joined Crisp White / Soft Charcoal block (Mentah)
            Expanded(
              flex: 1,
              child: ColoredBox(
                color: unripeBg,
                child: _MetricCell(
                  value: '$unripeCount',
                  label: 'Mentah',
                  valueColor: unripeFg,
                  labelColor: harvest.muted,
                  theme: theme,
                ),
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
    required this.valueColor,
    required this.labelColor,
    required this.theme,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Color labelColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12 + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
