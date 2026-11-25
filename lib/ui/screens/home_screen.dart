import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../providers/auth_providers.dart';
import '../../providers/camera_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/scan_notifier.dart';
import '../widgets/gallery_preview_sheet.dart';
import '../widgets/home_hero_scan_card.dart';
import '../widgets/home_quick_stats_row.dart';
import '../widgets/home_recent_scans_section.dart';
import '../widgets/home_recipes_section.dart';
import '../widgets/home_today_tip_card.dart';
import '../widgets/industrial_art.dart';

/// Main BananaLens home screen with a focused 6-block hierarchy:
/// 1. Header greeting + profile avatar
/// 2. Hero "Pindai Pisang" card (Camera + Gallery)
/// 3. 3-column scan metric strip (Total Pindai, Siap Santap, Mentah)
/// 4. Recent scans with real thumbnails
/// 5. Recommended banana recipes
/// 6. Single daily insight card
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isBusyGallery = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _pickFromGallery() async {
    if (_isBusyGallery) return;
    setState(() => _isBusyGallery = true);
    try {
      final photoSource = ref.read(photoSourceProvider);
      while (mounted) {
        final path = await photoSource.pickFromGallery();
        if (path == null || !mounted) return;

        final action = await showGalleryPreviewSheet(context, path);
        if (!mounted || action == null) return;
        if (action == GalleryPreviewAction.repick) continue;

        await ref.read(scanProvider.notifier).scan(path);
        if (mounted) {
          await context.push('/result');
        }
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _isBusyGallery = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    final historyAsync = ref.watch(historyListProvider);
    final name = userProfile?.name.split(' ').first ?? 'Sobat Sehat';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
                vertical: AppDimens.s12,
              ),
              children: [
                // 1. Header Sapaan & Avatar
                _HomeHeader(
                  greeting: _getGreeting(),
                  name: name,
                  harvest: harvest,
                  theme: theme,
                ),
                const SizedBox(height: AppDimens.s16),

                // 2. Hero "Pindai Pisang"
                HomeHeroScanCard(
                  isBusy: _isBusyGallery,
                  onScanTap: () => context.go('/scan'),
                  onGalleryTap: _pickFromGallery,
                ),
                const SizedBox(height: AppDimens.s16),

                // 3. Strip Statistik Pindai
                HomeQuickStatsRow(
                  historyAsync: historyAsync,
                  onStatTap: (filter) => context.go('/history?filter=$filter'),
                ),
                const SizedBox(height: AppDimens.s20),

                // 4. Riwayat Terakhir
                HomeRecentScansSection(historyAsync: historyAsync),
                const SizedBox(height: AppDimens.s20),

                // 5. Resep Pilihan
                const HomeRecipesSection(),
                const SizedBox(height: AppDimens.s20),

                // 6. Tips Hari Ini (tunggal, tanpa duplikasi)
                const HomeTodayTipCard(),
                const SizedBox(height: AppDimens.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.name,
    required this.harvest,
    required this.theme,
  });

  final String greeting;
  final String name;
  final HarvestColors harvest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ink = theme.colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IndustrialBananaMark(size: 32),
                  const SizedBox(width: AppDimens.s8),
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                '$greeting, $name',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Pantau kematangan pisang hari ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: harvest.muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.s12),
        Semantics(
          button: true,
          label: 'Buka profil saya',
          child: InkWell(
            onTap: () => context.go('/profile'),
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: harvest.accent,
                borderRadius: BorderRadius.circular(AppDimens.rButton),
              ),
              child: CustomPaint(
                foregroundPainter: ScannerCornerPainter(
                  color: theme.colorScheme.primary.withValues(alpha: 0.85),
                  bracketLength: 8,
                  strokeWidth: 1.4,
                  inset: 3,
                  style: ScannerCornerStyle.diagonal2,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: harvest.onAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
