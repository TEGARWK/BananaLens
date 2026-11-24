import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';

class RipenessChip extends StatelessWidget {
  const RipenessChip({super.key, required this.ripeness, this.showIcon = true});

  final Ripeness ripeness;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;

    final (label, icon, bg, fg) = switch (ripeness) {
      Ripeness.unripe => (
        'Mentah',
        Icons.eco_outlined,
        harvest.unripe,
        isDark ? theme.colorScheme.onPrimary : Colors.white,
      ),
      Ripeness.ripe => (
        'Matang',
        Icons.check_circle_outline,
        theme.colorScheme.primary,
        theme.colorScheme.onPrimary,
      ),
      Ripeness.overripe => (
        'Matang Banget',
        Icons.warning_amber_rounded,
        harvest.overripe,
        Colors.white,
      ),
      Ripeness.rotten => (
        'Busuk',
        Icons.dangerous_outlined,
        harvest.rotten,
        Colors.white,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8 + 2,
        vertical: AppDimens.s4 + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: AppDimens.s4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
