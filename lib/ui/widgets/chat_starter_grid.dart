import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Data model for a conversation-starter card on the empty Tanya AI state.
class ChatStarterItem {
  const ChatStarterItem({
    required this.title,
    required this.prompt,
    required this.icon,
  });

  final String title;
  final String prompt;
  final IconData icon;
}

/// 2-column (mobile) / up to 4-column (desktop) conversation starter grid
/// displayed right below the AI greeting when no user message has been sent.
class ChatStarterGrid extends StatelessWidget {
  const ChatStarterGrid({
    super.key,
    required this.hasContext,
    required this.onSelectPrompt,
  });

  final bool hasContext;
  final ValueChanged<String> onSelectPrompt;

  static const List<ChatStarterItem> _defaultItems = [
    ChatStarterItem(
      title: 'Kematangan Pisang',
      prompt: 'Bagaimana mengetahui pisang sudah matang?',
      icon: Icons.eco_outlined,
    ),
    ChatStarterItem(
      title: 'Resep Pisang',
      prompt: 'Apa yang bisa dibuat dari pisang matang?',
      icon: Icons.restaurant_menu_rounded,
    ),
    ChatStarterItem(
      title: 'Tips Penyimpanan',
      prompt: 'Bagaimana menyimpan pisang agar awet?',
      icon: Icons.inventory_2_outlined,
    ),
    ChatStarterItem(
      title: 'Tanya Hasil Scan',
      prompt: 'Bantu saya memahami hasil deteksi.',
      icon: Icons.center_focus_strong_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final items = hasContext
        ? [
            const ChatStarterItem(
              title: 'Keamanan Konsumsi',
              prompt: 'Apakah pisang ini masih aman dikonsumsi?',
              icon: Icons.verified_user_outlined,
            ),
            const ChatStarterItem(
              title: 'Resep Pisang',
              prompt: 'Ide olahan yang cocok untuk kondisi pisang ini?',
              icon: Icons.restaurant_menu_rounded,
            ),
            const ChatStarterItem(
              title: 'Tips Penyimpanan',
              prompt: 'Berapa lama dan bagaimana cara menyimpannya?',
              icon: Icons.inventory_2_outlined,
            ),
            const ChatStarterItem(
              title: 'Tanya Hasil Scan',
              prompt: 'Bantu saya memahami hasil deteksi.',
              icon: Icons.center_focus_strong_outlined,
            ),
          ]
        : _defaultItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppDimens.s16,
            bottom: AppDimens.s12,
          ),
          child: Text(
            'Mau tanya apa hari ini?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 680 ? 4 : 2;
            const gap = AppDimens.s8;
            final cardWidth =
                (constraints.maxWidth - (gap * (columns - 1))) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: _StarterCard(
                    item: item,
                    theme: theme,
                    harvest: harvest,
                    onTap: () => onSelectPrompt(item.prompt),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StarterCard extends StatelessWidget {
  const _StarterCard({
    required this.item,
    required this.theme,
    required this.harvest,
    required this.onTap,
  });

  final ChatStarterItem item;
  final ThemeData theme;
  final HarvestColors harvest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final ink = theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      label: '${item.title}: ${item.prompt}',
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.rCard),
              border: Border.all(color: harvest.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? harvest.primarySoft
                        : AppColors.lPrimary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                  ),
                  child: Icon(item.icon, size: 17, color: ink),
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ink,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: harvest.muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
