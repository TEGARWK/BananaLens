import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

class NutrientTile extends StatelessWidget {
  const NutrientTile({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12,
      ),
      decoration: BoxDecoration(
        color: harvest.primarySoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        border: Border.all(
          color: harvest.border.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: AppDimens.s4),
              Text(
                unit,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.8,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: harvest.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
