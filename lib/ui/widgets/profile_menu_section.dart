import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/ui/widgets/app_card.dart';

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

/// Clean grouped menu card for Account Settings and General Settings.
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
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: harvest.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.s8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _MenuRowTile(item: items[i]),
                if (i < items.length - 1) const Divider(height: 1),
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
    final accent = item.isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final badgeBg = item.isDestructive
        ? theme.colorScheme.error.withValues(alpha: 0.12)
        : harvest.primarySoft;

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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(AppDimens.rButton),
              ),
              child: Icon(item.icon, size: 20, color: accent),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: item.isDestructive ? accent : null,
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
            Icon(Icons.chevron_right_rounded, color: harvest.muted),
          ],
        ),
      ),
    );
  }
}
