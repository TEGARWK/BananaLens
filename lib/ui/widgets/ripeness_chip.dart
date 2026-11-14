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
    final color = harvest.forRipeness(ripeness);

    final (label, icon) = switch (ripeness) {
      Ripeness.unripe => ('Mentah', Icons.eco_outlined),
      Ripeness.ripe => ('Matang', Icons.check_circle_outline),
      Ripeness.overripe => ('Terlalu matang', Icons.warning_amber_rounded),
      Ripeness.rotten => ('Busuk', Icons.dangerous_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s4 + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppDimens.s4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
