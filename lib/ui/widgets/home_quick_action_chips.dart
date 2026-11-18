import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// 3 Quick Action Chips: Tips Buah, Asisten AI, Resep Sehat
class HomeQuickActionChips extends StatelessWidget {
  const HomeQuickActionChips({
    super.key,
    required this.onTipsTap,
    required this.onAiTap,
    required this.onRecipeTap,
  });

  final VoidCallback onTipsTap;
  final VoidCallback onAiTap;
  final VoidCallback onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Row(
      children: [
        Expanded(
          child: _ChipButton(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Tips Buah',
            color: harvest.primarySoft,
            iconColor: theme.colorScheme.primary,
            onTap: onTipsTap,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _ChipButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Asisten AI',
            color: harvest.accent.withValues(alpha: 0.15),
            iconColor: harvest.accent,
            onTap: onAiTap,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _ChipButton(
            icon: Icons.restaurant_menu_rounded,
            label: 'Resep Sehat',
            color: harvest.primarySoft,
            iconColor: theme.colorScheme.primary,
            onTap: onRecipeTap,
          ),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s8,
          vertical: AppDimens.s4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          border: Border.all(color: harvest.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: AppDimens.s4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
