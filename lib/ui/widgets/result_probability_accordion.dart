import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import 'industrial_art.dart';

/// Collapsible accordion displaying the per-class SVM ripeness probabilities.
/// Collapsed by default so the primary result and SPK action remain above the fold.
class ResultProbabilityAccordion extends StatefulWidget {
  const ResultProbabilityAccordion({super.key, required this.probabilities});

  final Map<String, double> probabilities;

  @override
  State<ResultProbabilityAccordion> createState() =>
      _ResultProbabilityAccordionState();
}

class _ResultProbabilityAccordionState
    extends State<ResultProbabilityAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final ordered = _orderedProbabilities(widget.probabilities);

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s16,
        vertical: AppDimens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppDimens.rSharp),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  ),
                  child: Icon(Icons.bar_chart_rounded, size: 16, color: ink),
                ),
                const SizedBox(width: AppDimens.s8),
                Expanded(
                  child: Text(
                    'Lihat rincian skor AI',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: ink,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: AppDimens.s12),
            ...ordered.map((entry) => _buildBar(context, entry, ink, harvest)),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    MapEntry<String, double> entry,
    Color ink,
    HarvestColors harvest,
  ) {
    final theme = Theme.of(context);
    final rawClass = entry.key;
    final prob = entry.value;
    final rip = Ripeness.fromLabel(rawClass);
    final barColor = switch (rip) {
      Ripeness.unripe => harvest.unripe,
      Ripeness.ripe => theme.colorScheme.primary,
      Ripeness.overripe => harvest.overripe,
      Ripeness.rotten => harvest.rotten,
      null => theme.colorScheme.primary,
    };
    final labelIndo = switch (rawClass) {
      'unripe' => 'Mentah',
      'ripe' => 'Matang',
      'overripe' => 'Matang Banget',
      'rotten' => 'Busuk',
      _ => rawClass,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  labelIndo,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
              Text(
                '${(prob * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: harvest.primarySoft,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: prob.clamp(0.0, 1.0),
                child: ColoredBox(
                  color: barColor,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, double>> _orderedProbabilities(
    Map<String, double> probabilities,
  ) {
    const order = <String>['unripe', 'ripe', 'overripe', 'rotten'];
    final entries = probabilities.entries.toList();
    entries.sort((a, b) {
      final idxA = order.indexOf(a.key);
      final idxB = order.indexOf(b.key);
      return (idxA == -1 ? order.length : idxA).compareTo(
        idxB == -1 ? order.length : idxB,
      );
    });
    return entries;
  }
}
