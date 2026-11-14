import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import '../../providers/auth_providers.dart';
import '../../providers/camera_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/scan_notifier.dart';
import '../../providers/service_providers.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/fruit_vector_icon.dart';
import '../widgets/ripeness_chip.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/soft_button.dart';

/// Screen utama FruitLens dengan susunan informasi lengkap:
/// 1. Sapaan + Avatar
/// 2. Hero "Cek Kesegaran Buah" (Kamera + Dari Galeri)
/// 3. Aksi Cepat (3 chip)
/// 4. Statistik Ringkas (Total scan, Buah matang, Buah favorit)
/// 5. Pengingat Buah & Rekomendasi Personal
/// 6. Riwayat Terakhir
/// 7. Resep Rekomendasi (horizontal)
/// 8. Tips Hari Ini (2 baris + Baca selengkapnya)
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
            // 1. Sapaan + Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
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
                        '${_getGreeting()}, $name 👋',
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
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    width: 44,
                    height: 44,
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
              ],
            ),
            const SizedBox(height: AppDimens.s16),

            // 2. Hero "Cek Kesegaran Buah" (Gambar apel di kanan atas, opsi Kamera & Galeri)
            _HeroScanCard(
              onScanTap: () => context.go('/scan'),
              onGalleryTap: () => _pickFromGallery(context, ref),
            ),
            const SizedBox(height: AppDimens.s12),

            // 3. Aksi Cepat (3 Chip: Scan dari galeri, Asisten AI, Resep hari ini)
            _QuickActionChips(
              onGalleryTap: () => _pickFromGallery(context, ref),
              onAiTap: () => context.go('/chat'),
              onRecipeTap: () => context.go('/recipes'),
            ),
            const SizedBox(height: AppDimens.s16),

            // 4. Statistik Ringkas (Total scan, Buah matang, Buah favorit)
            _QuickStatsRow(historyAsync: historyAsync),
            const SizedBox(height: AppDimens.s16),

            // 5. Pengingat Buah Hampir Busuk & Rekomendasi Personal
            _SmartReminderCard(historyAsync: historyAsync),
            const SizedBox(height: AppDimens.s16),

            // 6. Riwayat Terakhir
            SectionHeader(
              title: 'Riwayat Terakhir',
              actionText: 'Lihat semua',
              onAction: () => context.go('/history'),
            ),
            const SizedBox(height: AppDimens.s8),

            historyAsync.when(
              loading: () => const AppCard(
                child: Column(
                  children: [
                    ShimmerBox(height: 52, radius: AppDimens.s12),
                    SizedBox(height: AppDimens.s8),
                    ShimmerBox(height: 52, radius: AppDimens.s12),
                  ],
                ),
              ),
              error: (err, _) => AppCard(
                child: Text(
                  'Gagal memuat riwayat: $err',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppCard(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.s20),
                    child: EmptyState(
                      icon: Icons.history_rounded,
                      title: 'Belum Ada Riwayat',
                      message:
                          'Pindai buah pertamamu untuk melihat hasil analisis kematangan dan nutrisi di sini.',
                    ),
                  );
                }
                final recents = items.take(3).toList();
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < recents.length; i++) ...[
                        InkWell(
                          onTap: () => context.push(
                            '/history-detail',
                            extra: recents[i],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: i == 0
                                ? const Radius.circular(AppDimens.rCard)
                                : Radius.zero,
                            bottom: i == recents.length - 1
                                ? const Radius.circular(AppDimens.rCard)
                                : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.s16),
                            child: Row(
                              children: [
                                FruitVectorIcon(
                                  fruitLabel: recents[i].fruitLabel,
                                  size: 44,
                                  isCircular: true,
                                ),
                                const SizedBox(width: AppDimens.s12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getFruitNameId(recents[i].fruitLabel),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_formatDate(recents[i].createdAt)} · ${(recents[i].confidence * 100).toStringAsFixed(0)}% yakin',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(color: harvest.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Ripeness.fromLabel(
                                      recents[i].ripenessLabel,
                                    ) !=
                                    null)
                                  RipenessChip(
                                    ripeness: Ripeness.fromLabel(
                                      recents[i].ripenessLabel,
                                    )!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (i < recents.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: harvest.border,
                            indent: AppDimens.s16,
                            endIndent: AppDimens.s16,
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.s20),

            // 7. Rekomendasi Resep untuk Hari Ini (Geser Horizontal)
            const _RecommendedRecipesSection(),
            const SizedBox(height: AppDimens.s20),

            // 8. Tips Hari Ini (Dipindah ke bawah, 2 baris + Baca selengkapnya)
            const _TodayTipCard(),
            const SizedBox(height: AppDimens.s24),
          ],
        ),
      ),
    );
  }

  static String _getFruitNameId(String fruitLabel) {
    return switch (fruitLabel.toLowerCase()) {
      'banana' => 'Pisang',
      'apple' => 'Apel',
      'avocado' => 'Alpukat',
      'orange' => 'Jeruk',
      'mango' => 'Mangga',
      'watermelon' => 'Semangka',
      'strawberry' => 'Stroberi',
      'pineapple' => 'Nanas',
      'papaya' => 'Pepaya',
      'grape' => 'Anggur',
      'tomato' => 'Tomat',
      _ => fruitLabel.toUpperCase(),
    };
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Hero Scan Card dengan tombol "Mulai Scan" (Kamera) dan opsi "Dari Galeri"
class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard({required this.onScanTap, required this.onGalleryTap});

  final VoidCallback onScanTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundDecoration = isDark
        ? BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            border: Border.all(color: harvest.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E9E5B), Color(0xFF1B6A3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          );

    final titleColor = isDark ? theme.colorScheme.onSurface : Colors.white;
    final subtitleColor = isDark
        ? harvest.muted
        : Colors.white.withValues(alpha: 0.88);

    return Container(
      decoration: backgroundDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ilustrasi buah apel digeser ke kanan-atas agar tidak menabrak tombol
          Positioned(
            right: -10,
            top: -12,
            child: Transform.rotate(
              angle: -0.15,
              child: Opacity(
                opacity: isDark ? 0.35 : 0.85,
                child: const FruitVectorIcon(
                  fruitLabel: 'apple',
                  size: 115,
                  isCircular: false,
                ),
              ),
            ),
          ),
          // Konten teks & tombol aksi
          Padding(
            padding: const EdgeInsets.all(AppDimens.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cek Kesegaran Buah',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.s8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    'Arahkan kamera ke buah untuk deteksi instan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                // Dua tombol aksi: Mulai Scan (Kamera) & Dari Galeri
                Row(
                  children: [
                    AccentButton(
                      text: 'Mulai Scan',
                      icon: Icons.camera_alt_rounded,
                      height: 40,
                      onPressed: onScanTap,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    InkWell(
                      onTap: onGalleryTap,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: AppDimens.s4),
                            Text(
                              'Galeri',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 Chip Aksi Cepat: Scan dari galeri, Asisten AI, Resep hari ini
class _QuickActionChips extends StatelessWidget {
  const _QuickActionChips({
    required this.onGalleryTap,
    required this.onAiTap,
    required this.onRecipeTap,
  });

  final VoidCallback onGalleryTap;
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
            icon: Icons.image_search_rounded,
            label: 'Scan Galeri',
            color: harvest.primarySoft,
            iconColor: theme.colorScheme.primary,
            onTap: onGalleryTap,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s8,
          vertical: AppDimens.s8,
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: AppDimens.s4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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

/// Baris 3 Kotak Statistik Ringkas: Total Scan, Buah Matang, Buah Favorit
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final items = historyAsync.asData?.value ?? <ScanResult>[];
    final totalScan = items.length;
    final ripeCount = items.where((e) => e.ripenessLabel == 'ripe').length;

    // Hitung buah yang paling sering discan
    String favoriteFruit = '-';
    if (items.isNotEmpty) {
      final counts = <String, int>{};
      for (final item in items) {
        counts[item.fruitLabel] = (counts[item.fruitLabel] ?? 0) + 1;
      }
      var maxCount = 0;
      var topFruit = '';
      counts.forEach((fruit, count) {
        if (count > maxCount) {
          maxCount = count;
          topFruit = fruit;
        }
      });
      favoriteFruit = HomeScreen._getFruitNameId(topFruit);
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.qr_code_scanner_rounded,
            iconColor: theme.colorScheme.primary,
            title: '$totalScan',
            subtitle: 'Total Scan',
            harvest: harvest,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: harvest.ripe,
            title: '$ripeCount',
            subtitle: 'Buah Matang',
            harvest: harvest,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_border_rounded,
            iconColor: Colors.redAccent,
            title: favoriteFruit,
            subtitle: 'Buah Favorit',
            harvest: harvest,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.harvest,
    required this.theme,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final HarvestColors harvest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: iconColor),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: harvest.muted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pengingat Buah Cerdas & Rekomendasi Personal
class _SmartReminderCard extends ConsumerWidget {
  const _SmartReminderCard({required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final items = historyAsync.asData?.value ?? <ScanResult>[];
    final userProfile = ref.watch(authNotifierProvider).asData?.value;

    // Cek apakah ada buah yang discan yang matang / hampir busuk
    final recentRipe = items.cast<ScanResult?>().firstWhere(
      (e) =>
          e != null &&
          (e.ripenessLabel == 'ripe' || e.ripenessLabel == 'overripe'),
      orElse: () => null,
    );

    String reminderText;
    IconData reminderIcon;
    Color reminderColor;

    if (recentRipe != null) {
      final fruitName = HomeScreen._getFruitNameId(recentRipe.fruitLabel);
      reminderText =
          '$fruitName yang kamu scan siap disantap atau diolah menjadi smoothie sebelum terlalu matang!';
      reminderIcon = Icons.alarm_rounded;
      reminderColor = harvest.accent;
    } else {
      reminderText =
          'Tahukah kamu? Simpan buah matang terpisah agar gas etilen tidak membuat buah lain cepat busuk.';
      reminderIcon = Icons.eco_rounded;
      reminderColor = theme.colorScheme.primary;
    }

    final goalText = userProfile?.goal != null && userProfile!.goal.isNotEmpty
        ? 'Cocok untuk target ${userProfile.goal}: Perbanyak asupan apel & alpukat kaya serat.'
        : 'Rekomendasi diet sehat: Konsumsi minimal 2 porsi buah segar setiap hari.';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.s8),
                decoration: BoxDecoration(
                  color: reminderColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(reminderIcon, size: 18, color: reminderColor),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Kesegaran',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminderText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Divider(height: 1, color: harvest.border),
          const SizedBox(height: AppDimens.s8),
          Row(
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 15,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppDimens.s4),
              Expanded(
                child: Text(
                  goalText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rekomendasi Resep untuk Hari Ini (Kartu Horizontal Geser)
class _RecommendedRecipesSection extends ConsumerWidget {
  const _RecommendedRecipesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final recipeRepo = ref.watch(recipeRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Resep Rekomendasi',
          actionText: 'Lihat semua',
          onAction: () => context.go('/recipes'),
        ),
        const SizedBox(height: AppDimens.s8),
        FutureBuilder<List<Recipe>>(
          future: recipeRepo.getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(height: 140, radius: AppDimens.rCard),
                    ),
                    SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: ShimmerBox(height: 140, radius: AppDimens.rCard),
                    ),
                  ],
                ),
              );
            }

            final recipes = snapshot.data ?? <Recipe>[];
            if (recipes.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recipes.length.clamp(0, 5),
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppDimens.s12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];

                  return InkWell(
                    onTap: () => context.push('/recipe-detail', extra: recipe),
                    borderRadius: BorderRadius.circular(AppDimens.rCard),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(AppDimens.s12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppDimens.rCard),
                        border: Border.all(color: harvest.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FruitVectorIcon(
                                fruitLabel: recipe.fruitLabel,
                                size: 36,
                                isCircular: true,
                              ),
                              const SizedBox(width: AppDimens.s8),
                              Expanded(
                                child: Text(
                                  recipe.prepTime,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: harvest.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: harvest.primarySoft,
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.rPill,
                                  ),
                                ),
                                child: Text(
                                  recipe.difficulty,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            recipe.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: AppDimens.s4),
                          Text(
                            '${recipe.ingredients.length} bahan pilihan',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: harvest.muted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Tips Hari Ini (2 baris ringkas + Tombol "Baca selengkapnya" dengan modal dialog)
class _TodayTipCard extends StatelessWidget {
  const _TodayTipCard();

  static const List<_FruitTipItem> _tipsList = [
    _FruitTipItem(
      title: 'Pisang Bintik Cokelat',
      shortText:
          'Pisang berbintik cokelat memiliki kandungan antioksidan dan gula alami tertinggi.',
      fullText:
          'Bintik hitam pada kulit pisang menandakan produksi Tumor Necrosis Factor (TNF) dan antioksidan yang optimal. Sangat manis alami, mudah dicerna, dan sempurna untuk bahan smoothie atau pancake sehat tanpa tambahan gula.',
      fruit: 'banana',
    ),
    _FruitTipItem(
      title: 'Cara Menyimpan Apel',
      shortText:
          'Simpan apel di kulkas dan jauhkan dari buah sensitif agar tidak cepat layu.',
      fullText:
          'Apel melepaskan gas etilen dalam jumlah tinggi yang mempercepat pematangan buah lain di sekitarnya. Simpan di laci bawah kulkas dengan kantong berpori agar kesegarannya bertahan hingga sebulan.',
      fruit: 'apple',
    ),
    _FruitTipItem(
      title: 'Alpukat Matang Sempurna',
      shortText:
          'Tekan lembut pangkal tangkai alpukat untuk memastikan kematangan tanpa merusak dagingnya.',
      fullText:
          'Jika tangkai kecil di atas mudah lepas dan memperlihatkan warna hijau muda di bawahnya, alpukat siap dinikmati! Mengandung asam lemak tak jenuh tunggal yang sangat baik bagi kesehatan jantung.',
      fruit: 'avocado',
    ),
  ];

  void _showTipDialog(BuildContext context, _FruitTipItem tip) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppDimens.s20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.rSheet),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: harvest.border,
                      borderRadius: BorderRadius.circular(AppDimens.rPill),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                Row(
                  children: [
                    FruitVectorIcon(
                      fruitLabel: tip.fruit,
                      size: 44,
                      isCircular: true,
                    ),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Edukasi Nutrisi',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            tip.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s16),
                Text(
                  tip.fullText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimens.s20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Tutup Tips'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    // Ambil tip berdasarkan hari dalam seminggu
    final dayIndex = DateTime.now().weekday % _tipsList.length;
    final tip = _tipsList[dayIndex];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips Hari Ini: ${tip.title}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      tip.shortText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showTipDialog(context, tip),
              borderRadius: BorderRadius.circular(AppDimens.rPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Baca selengkapnya',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitTipItem {
  const _FruitTipItem({
    required this.title,
    required this.shortText,
    required this.fullText,
    required this.fruit,
  });

  final String title;
  final String shortText;
  final String fullText;
  final String fruit;
}
