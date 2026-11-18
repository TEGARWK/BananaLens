import 'package:flutter/material.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_colors.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';
import 'package:fruitlens/data/models/fruit_info.dart';

/// Redesigned Nutrition Panel blending Apple Health metrics with clean visual gauges.
class NutritionPanel extends StatelessWidget {
  const NutritionPanel({required this.info, super.key});

  final FruitInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. Lead Calories Card (Apple Health Ring/Hero metric)
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                scheme.primaryContainer.withValues(alpha: 0.7),
                scheme.primaryContainer.withValues(alpha: 0.35),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ENERGI PER 100 GRAM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        _format(info.calories),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${AppStrings.resultUnitKcal} · ${AppStrings.resultCalories}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.secondary.withValues(alpha: 0.18)
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : scheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: isDark ? scheme.secondary : AppColors.secondarySeed,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2. Macronutrient Bento Cards (Carbs, Sugar, Fiber)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _MacroBento(
                label: AppStrings.resultCarbs,
                value: info.carbs,
                barColor: isDark
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFFEF6C00),
                icon: Icons.grain_rounded,
              ),
              const SizedBox(width: AppSpacing.xs),
              _MacroBento(
                label: AppStrings.resultSugar,
                value: info.sugar,
                barColor: isDark
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFFF9A825),
                icon: Icons.water_drop_rounded,
              ),
              const SizedBox(width: AppSpacing.xs),
              _MacroBento(
                label: AppStrings.resultFiber,
                value: info.fiber,
                barColor: isDark
                    ? const Color(0xFF81C784)
                    : const Color(0xFF2E7D32),
                icon: Icons.eco_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroBento extends StatelessWidget {
  const _MacroBento({
    required this.label,
    required this.value,
    required this.barColor,
    required this.icon,
  });

  final String label;
  final double value;
  final Color barColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.mdSm,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 14, color: barColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_format(value)} ${AppStrings.resultUnitGram}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: AppRadius.roundedFull,
              child: LinearProgressIndicator(
                value: (value / 30.0).clamp(0.1, 1.0),
                backgroundColor: barColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Drops trailing ".0" for clean integers.
String _format(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
