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
            badgeColor: theme.colorScheme.primary,
            onTap: onTipsTap,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _ChipButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Asisten AI',
            badgeColor: harvest.primarySoft,
            onTap: onAiTap,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _ChipButton(
            icon: Icons.restaurant_menu_rounded,
            label: 'Resep Sehat',
            badgeColor: theme.colorScheme.primary,
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
    required this.badgeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rSharp),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s8,
          vertical: AppDimens.s4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          border: Border.all(color: ink, width: 1.3),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(2, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(AppDimens.rSharp),
                border: Border.all(color: ink, width: 1),
              ),
              child: Icon(icon, size: 13, color: ink),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
