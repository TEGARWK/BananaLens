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
import '../widgets/home_hero_scan_card.dart';
import '../widgets/home_quick_action_chips.dart';
import '../widgets/home_quick_stats_row.dart';
import '../widgets/home_recent_scans_section.dart';
import '../widgets/home_recipes_section.dart';
import '../widgets/home_smart_reminder_card.dart';
import '../widgets/home_today_tip_card.dart';

/// Screen utama FruitLens dengan susunan informasi lengkap:
/// 1. Sapaan + Avatar
/// 2. Hero "Cek Kesegaran Buah" (Kamera + Dari Galeri)
/// 3. Aksi Cepat (3 chip: Tips Buah, Asisten AI, Resep Sehat)
/// 4. Statistik Ringkas (Total scan, Buah matang, Buah favorit)
/// 5. Pengingat Buah & Rekomendasi Personal
/// 6. Riwayat Terakhir
/// 7. Resep Rekomendasi (horizontal)
/// 8. Tips Hari Ini (dialog pembaca modal)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final photoSource = ref.read(photoSourceProvider);
    final path = await photoSource.pickFromGallery();
    if (path != null && context.mounted) {
      await ref.read(scanProvider.notifier).scan(path);
      if (context.mounted) {
        await context.push('/result');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    final historyAsync = ref.watch(historyListProvider);
    final name = userProfile?.name.split(' ').first ?? 'Sobat Sehat';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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

            // 2. Hero "Cek Kesegaran Buah"
            HomeHeroScanCard(
              onScanTap: () => context.go('/scan'),
              onGalleryTap: () => _pickFromGallery(context, ref),
            ),
            const SizedBox(height: AppDimens.s12),

            // 3. Aksi Cepat
            HomeQuickActionChips(
              onTipsTap: () {
                final dayIndex =
                    DateTime.now().weekday % HomeTodayTipCard.tipsList.length;
                HomeTodayTipCard.showTipDialog(
                  context,
                  HomeTodayTipCard.tipsList[dayIndex],
                );
              },
              onAiTap: () => context.go('/chat'),
              onRecipeTap: () => context.go('/recipes'),
            ),
            const SizedBox(height: AppDimens.s16),

            // 4. Statistik Ringkas
            HomeQuickStatsRow(historyAsync: historyAsync),
            const SizedBox(height: AppDimens.s16),

            // 5. Pengingat Buah Cerdas
            HomeSmartReminderCard(historyAsync: historyAsync),
            const SizedBox(height: AppDimens.s16),

            // 6. Riwayat Terakhir
            HomeRecentScansSection(historyAsync: historyAsync),
            const SizedBox(height: AppDimens.s20),

            // 7. Rekomendasi Resep
            const HomeRecipesSection(),
            const SizedBox(height: AppDimens.s20),

            // 8. Tips Hari Ini
            const HomeTodayTipCard(),
            const SizedBox(height: AppDimens.s24),
          ],
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
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s4),
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s4),
              Text(
                '$greeting, $name',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.s4),
              Text(
                'Mau cek kesegaran buah apa hari ini?',
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
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => context.go('/profile'),
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
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
