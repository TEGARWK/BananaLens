import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/scan_result.dart';
import 'app_card.dart';

/// 3 Quick Stat Cards: Total Scan, Buah Matang, Buah Favorit
class HomeQuickStatsRow extends StatelessWidget {
  const HomeQuickStatsRow({super.key, required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final items = historyAsync.asData?.value ?? <ScanResult>[];
    final totalScan = items.length;
    final ripeCount = items.where((e) => e.ripenessLabel == 'ripe').length;

    // Hitung buah yang paling sering discan
    String favoriteFruit = '-';
    if (items.isNotEmpty) {
      final counts = <String, int>{};
      for (final item in items) {
        counts[item.fruitLabel] = (counts[item.fruitLabel] ?? 0) + 1;
      }
      var maxCount = 0;
      var topFruit = '';
      counts.forEach((fruit, count) {
        if (count > maxCount) {
          maxCount = count;
          topFruit = fruit;
        }
      });
      favoriteFruit = FruitNameHelper.toIndonesian(topFruit);
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.qr_code_scanner_rounded,
            iconColor: theme.colorScheme.primary,
            title: '$totalScan',
            subtitle: 'Total Scan',
            harvest: harvest,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: harvest.ripe,
            title: '$ripeCount',
            subtitle: 'Buah Matang',
            harvest: harvest,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_border_rounded,
            iconColor: theme.brightness == Brightness.dark
                ? const Color(0xFFFF6B70)
                : const Color(0xFFE5484D),
            title: favoriteFruit,
            subtitle: 'Buah Favorit',
            harvest: harvest,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.harvest,
    required this.theme,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final HarvestColors harvest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: iconColor),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: harvest.muted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
