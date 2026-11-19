import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';

/// Configuration row model for grouped settings sections.
class ProfileMenuItem {
  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// Tactile grouped menu card for Account Settings and General Settings.
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.s4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(
                    color: theme.colorScheme.onSurface,
                    width: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s8),
        IndustrialSpecimenCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _MenuRowTile(item: items[i]),
                if (i < items.length - 1)
                  Divider(height: 1, color: harvest.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRowTile extends StatelessWidget {
  const _MenuRowTile({required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final iconColor = item.isDestructive ? theme.colorScheme.error : ink;
    final badgeBg = item.isDestructive
        ? theme.colorScheme.error.withValues(alpha: 0.14)
        : theme.colorScheme.primary.withValues(alpha: 0.45);
    final badgeBorder = item.isDestructive ? theme.colorScheme.error : ink;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppDimens.rCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                border: Border.all(color: badgeBorder, width: 1.3),
              ),
              child: Icon(item.icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.isDestructive ? theme.colorScheme.error : ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: harvest.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ink.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
