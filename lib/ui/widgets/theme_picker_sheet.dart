import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';

/// Returns a concise Indonesian display label for a [ThemeMode].
String themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'Ikuti Sistem',
    ThemeMode.light => 'Fresh Harvest (Terang)',
    ThemeMode.dark => 'Night Harvest (Gelap)',
  };
}

/// Tactile industrial modal bottom sheet for switching the app theme mode.
class ThemePickerSheet extends ConsumerWidget {
  const ThemePickerSheet({super.key});

  /// Opens the theme picker modal sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final current = ref.watch(themeControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.rHero),
        ),
        border: Border(top: BorderSide(color: ink, width: 1.6)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s20,
        AppDimens.s12,
        AppDimens.s20,
        AppDimens.s24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const IndustrialTagChip(
                  label: 'TEMA // TAMPILAN',
                  accent: true,
                ),
                Text(
                  'BANANALENS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            Text(
              'Tema & Tampilan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.s4),
            Text(
              'Pilih tampilan paling nyaman untuk matamu',
              style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
            ),
            const SizedBox(height: AppDimens.s16),
            _ThemeOptionTile(
              icon: Icons.brightness_auto_rounded,
              title: themeModeLabel(ThemeMode.system),
              subtitle: 'Menyesuaikan mode perangkat otomatis',
              selected: current == ThemeMode.system,
              onTap: () => _select(context, ref, ThemeMode.system),
            ),
            const SizedBox(height: AppDimens.s12),
            _ThemeOptionTile(
              icon: Icons.light_mode_rounded,
              title: themeModeLabel(ThemeMode.light),
              subtitle: 'Kertas teknis hangat & kuning terang',
              selected: current == ThemeMode.light,
              onTap: () => _select(context, ref, ThemeMode.light),
            ),
            const SizedBox(height: AppDimens.s12),
            _ThemeOptionTile(
              icon: Icons.dark_mode_rounded,
              title: themeModeLabel(ThemeMode.dark),
              subtitle: 'Nyaman dipakai di pencahayaan minim',
              selected: current == ThemeMode.dark,
              onTap: () => _select(context, ref, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    await ref.read(themeControllerProvider.notifier).setThemeMode(mode);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final primary = theme.colorScheme.primary;
    final ink = theme.colorScheme.onSurface;

    return Material(
      color: selected
          ? primary.withValues(alpha: 0.22)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s16,
            vertical: AppDimens.s12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            border: Border.all(
              color: selected ? ink : harvest.border,
              width: selected ? 1.6 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? primary : harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                  border: Border.all(
                    color: selected ? ink : harvest.border,
                    width: 1.3,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? theme.colorScheme.onPrimary : ink,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(
                    color: selected ? ink : harvest.muted,
                    width: 1.4,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
