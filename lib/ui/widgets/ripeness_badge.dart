import 'package:flutter/material.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_colors.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';
import 'package:fruitlens/data/models/ripeness.dart';

/// Pill showing ripeness with color AND icon + text (never color alone).
class RipenessBadge extends StatelessWidget {
  const RipenessBadge({required this.ripeness, super.key});

  final Ripeness ripeness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<RipenessColors>() ?? RipenessColors.light;
    final style = _styleFor(ripeness, colors);

    return Semantics(
      label: style.label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.container,
            borderRadius: AppRadius.roundedFull,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.mdSm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(style.icon, size: 18, color: style.content),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  style.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: style.content,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _BadgeStyle _styleFor(Ripeness value, RipenessColors c) {
    return switch (value) {
      Ripeness.unripe => _BadgeStyle(
        AppStrings.ripenessUnripe,
        Icons.eco_outlined,
        c.unripeContainer,
        c.onUnripeContainer,
      ),
      Ripeness.ripe => _BadgeStyle(
        AppStrings.ripenessRipe,
        Icons.check_circle_outline,
        c.ripeContainer,
        c.onRipeContainer,
      ),
      Ripeness.overripe => _BadgeStyle(
        AppStrings.ripenessOverripe,
        Icons.warning_amber_rounded,
        c.overripeContainer,
        c.onOverripeContainer,
      ),
      Ripeness.rotten => _BadgeStyle(
        AppStrings.ripenessRotten,
        Icons.cancel_outlined,
        c.rottenContainer,
        c.onRottenContainer,
      ),
    };
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.label, this.icon, this.container, this.content);

  final String label;
  final IconData icon;
  final Color container;
  final Color content;
}
