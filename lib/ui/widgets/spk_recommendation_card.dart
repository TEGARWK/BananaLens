import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../services/recipe_gating_service.dart';
import '../../services/spk_decision_service.dart';
import 'industrial_art.dart';
import 'primary_button.dart';
import 'soft_button.dart';

/// Displays the PSO-Random Forest SPK decision card. Context selector chips
/// (`Rencana pakai` & `Tujuan`) sit at the top so the flow reads naturally:
/// choose context -> see decision & tips -> take action.
class SpkRecommendationCard extends StatelessWidget {
  const SpkRecommendationCard({
    super.key,
    required this.plan,
    required this.showContextSelectors,
    required this.allowedTargetDays,
    required this.allowedUsageGoals,
    required this.targetDays,
    required this.usageGoal,
    required this.onTargetDaysChanged,
    required this.onUsageGoalChanged,
    required this.onOpenRecipes,
    this.onOpenRecycleTips,
  });

  final SpkActionPlan plan;
  final bool showContextSelectors;
  final List<SpkTargetDays> allowedTargetDays;
  final List<SpkUsageGoal> allowedUsageGoals;
  final SpkTargetDays targetDays;
  final SpkUsageGoal usageGoal;
  final ValueChanged<SpkTargetDays> onTargetDaysChanged;
  final ValueChanged<SpkUsageGoal> onUsageGoalChanged;
  final ValueChanged<RipenessBucket> onOpenRecipes;
  final VoidCallback? onOpenRecycleTips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final decision = plan.decision;
    final accent = _accentForClass(decision.id, theme, harvest);
    final bgColor = plan.isDiscard || plan.isWaitOrStore
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.12),
            theme.colorScheme.surface,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: IndustrialSpecimenCard(
        backgroundColor: bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showContextSelectors) ...[
              _SelectorGroup<SpkTargetDays>(
                label: 'Rencana pakai',
                values: allowedTargetDays,
                selected: targetDays,
                labelOf: (v) => v.labelId,
                onSelected: onTargetDaysChanged,
              ),
              const SizedBox(height: AppDimens.s8),
              _SelectorGroup<SpkUsageGoal>(
                label: 'Tujuan',
                values: allowedUsageGoals,
                selected: usageGoal,
                labelOf: (v) => v.labelId,
                onSelected: onUsageGoalChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.s12),
                child: Divider(height: 1, color: ink.withValues(alpha: 0.16)),
              ),
            ],
            _HeaderRow(
              decision: decision,
              accent: accent,
              ink: ink,
              isDiscard: plan.isDiscard,
              isWaitOrStore: plan.isWaitOrStore,
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              decision.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ink.withValues(alpha: 0.88),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            _ActionTipBox(tips: decision.actionTips, accent: accent, ink: ink),
            if (plan.recipeBucket != null) ...[
              const SizedBox(height: AppDimens.s12),
              PrimaryButton(
                text: 'Rekomendasi Resep',
                icon: Icons.restaurant_menu_rounded,
                onPressed: () => onOpenRecipes(plan.recipeBucket!),
              ),
            ] else if (plan.isDiscard && onOpenRecycleTips != null) ...[
              const SizedBox(height: AppDimens.s12),
              SoftButton(
                text: AppStrings.rottenRecycleButton,
                icon: Icons.compost_rounded,
                onPressed: onOpenRecycleTips,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentForClass(int id, ThemeData theme, HarvestColors harvest) {
    return switch (id) {
      0 => harvest.unripe,
      1 => theme.colorScheme.primary,
      2 => harvest.overripe,
      3 => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.decision,
    required this.accent,
    required this.ink,
    required this.isDiscard,
    required this.isWaitOrStore,
  });

  final SpkDecisionClass decision;
  final Color accent;
  final Color ink;
  final bool isDiscard;
  final bool isWaitOrStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = isDiscard
        ? Icons.dangerous_rounded
        : (isWaitOrStore ? Icons.schedule_rounded : Icons.auto_awesome_rounded);
    final badgeTextColor = isDiscard
        ? theme.colorScheme.onError
        : (decision.id == 1 ? theme.colorScheme.onPrimary : Colors.white);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppDimens.rSharp),
            border: Border.all(color: ink, width: 1.2),
          ),
          child: Icon(icon, size: 16, color: ink),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                decision.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDiscard ? theme.colorScheme.error : ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.0),
                ),
                child: Text(
                  decision.badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTipBox extends StatelessWidget {
  const _ActionTipBox({
    required this.tips,
    required this.accent,
    required this.ink,
  });

  final String tips;
  final Color accent;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.s12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: ink.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: ink),
          const SizedBox(width: AppDimens.s8),
          Expanded(
            child: Text(
              tips,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ink.withValues(alpha: 0.85),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorGroup<T> extends StatelessWidget {
  const _SelectorGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ink.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: AppDimens.s8,
          runSpacing: AppDimens.s8,
          children: values.map((item) {
            final isSelected = item == selected;
            return InkWell(
              onTap: () => onSelected(item),
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(
                    color: isSelected ? ink : harvest.border,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Text(
                  labelOf(item),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? theme.colorScheme.onPrimary : ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
