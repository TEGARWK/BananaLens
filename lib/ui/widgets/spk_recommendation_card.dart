import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../services/recipe_gating_service.dart';
import '../../services/spk_context_interpreter.dart';
import '../../services/spk_decision_service.dart';
import 'industrial_art.dart';
import 'primary_button.dart';
import 'soft_button.dart';

/// Displays the Hybrid PSO-Random Forest SPK decision card with contextual
/// interpretation tailored to the banana's ripeness, timeframe, and usage goal.
class SpkRecommendationCard extends StatelessWidget {
  const SpkRecommendationCard({
    super.key,
    required this.plan,
    required this.ripenessLabel,
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
  final String ripenessLabel;
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
    final isDark = theme.brightness == Brightness.dark;
    final decision = plan.decision;

    final advice = SpkContextInterpreter.interpret(
      ripenessLabel: ripenessLabel,
      targetDays: targetDays,
      usageGoal: usageGoal,
      baseDecision: decision,
    );
    final (suitBg, suitFg, suitIcon) = _suitabilityStyle(
      advice.suitability,
      theme,
      harvest,
      isDark,
    );
    final confPct = (plan.confidence * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: IndustrialSpecimenCard(
        backgroundColor: plan.isDiscard
            ? Color.alphaBlend(
                theme.colorScheme.error.withValues(alpha: 0.08),
                theme.colorScheme.surface,
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REKOMENDASI SPK',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: harvest.primarySoft,
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  ),
                  child: Text(
                    'PSO-RF · $confPct%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            if (showContextSelectors) ...[
              const SizedBox(height: AppDimens.s12),
              _SelectorGroup<SpkTargetDays>(
                label: 'Rencana pakai',
                values: allowedTargetDays,
                selected: targetDays,
                labelOf: (v) => v.labelId,
                onSelected: onTargetDaysChanged,
              ),
              const SizedBox(height: AppDimens.s8 + 2),
              _SelectorGroup<SpkUsageGoal>(
                label: 'Tujuan',
                values: allowedUsageGoals,
                selected: usageGoal,
                labelOf: (v) => v.labelId,
                onSelected: onUsageGoalChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.s12),
                child: Divider(height: 1, color: harvest.border),
              ),
            ] else
              const SizedBox(height: AppDimens.s12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey(
                  '${targetDays.code}-${usageGoal.code}-${decision.id}',
                ),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AdviceHeader(
                    headline: advice.headline,
                    suitabilityLabel: advice.suitability.labelId,
                    modelBadge: decision.badge,
                    suitBg: suitBg,
                    suitFg: suitFg,
                    suitIcon: suitIcon,
                    ink: ink,
                    isDiscard: plan.isDiscard,
                  ),
                  const SizedBox(height: AppDimens.s8 + 2),
                  Text(
                    advice.reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ink.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s8 + 2),
                  _ActionTipBox(
                    tips: advice.actionTip,
                    accent: suitFg,
                    ink: ink,
                  ),
                ],
              ),
            ),
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

  (Color, Color, IconData) _suitabilityStyle(
    SpkSuitability suitability,
    ThemeData theme,
    HarvestColors harvest,
    bool isDark,
  ) {
    return switch (suitability) {
      SpkSuitability.ideal => (
        isDark ? AppColors.dLeafSoft : AppColors.lLeafSoft,
        isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong,
        Icons.check_circle_rounded,
      ),
      SpkSuitability.adjust => (
        harvest.primarySoft,
        harvest.overripe,
        Icons.tune_rounded,
      ),
      SpkSuitability.notRecommended => (
        theme.colorScheme.error.withValues(alpha: 0.12),
        theme.colorScheme.error,
        Icons.warning_amber_rounded,
      ),
    };
  }
}

class _AdviceHeader extends StatelessWidget {
  const _AdviceHeader({
    required this.headline,
    required this.suitabilityLabel,
    required this.modelBadge,
    required this.suitBg,
    required this.suitFg,
    required this.suitIcon,
    required this.ink,
    required this.isDiscard,
  });

  final String headline;
  final String suitabilityLabel;
  final String modelBadge;
  final Color suitBg;
  final Color suitFg;
  final IconData suitIcon;
  final Color ink;
  final bool isDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: suitBg,
            borderRadius: BorderRadius.circular(AppDimens.rButton),
          ),
          child: Icon(suitIcon, size: 18, color: suitFg),
        ),
        const SizedBox(width: AppDimens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: suitBg,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    ),
                    child: Text(
                      suitabilityLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: suitFg,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: harvest.primarySoft,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    ),
                    child: Text(
                      modelBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                headline,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDiscard ? theme.colorScheme.error : ink,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
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
    final harvest = context.harvest;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        border: Border.all(color: harvest.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.s12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 16, color: ink),
                    const SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: Text(
                        tips,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ink.withValues(alpha: 0.88),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            color: harvest.muted,
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
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : harvest.border,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  labelOf(item),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
