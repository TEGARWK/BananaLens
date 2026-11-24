import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/fruit_info.dart';
import '../../data/models/ripeness.dart';
import 'industrial_art.dart';
import 'nutrient_tile.dart';

/// Displays BananaLens calorie banner and 3 macro nutrient tiles.
class HistoryDetailNutritionSection extends StatelessWidget {
  const HistoryDetailNutritionSection({super.key, required this.info});

  final FruitInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s16,
              vertical: AppDimens.s12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppDimens.rCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      info.calories.toStringAsFixed(0),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      'kkal · Kalori',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8 + 2,
                    vertical: AppDimens.s4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  ),
                  child: Text(
                    'Per 100 g',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),
          Row(
            children: [
              Expanded(
                child: NutrientTile(
                  value: info.carbs.toStringAsFixed(1),
                  unit: 'g',
                  label: 'Karbohidrat',
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Expanded(
                child: NutrientTile(
                  value: info.sugar.toStringAsFixed(1),
                  unit: 'g',
                  label: 'Gula Alami',
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Expanded(
                child: NutrientTile(
                  value: info.fiber.toStringAsFixed(1),
                  unit: 'g',
                  label: 'Serat Pangan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Displays ripeness-aware consumption and storage/handling guidance.
class HistoryDetailGuidanceCard extends StatelessWidget {
  const HistoryDetailGuidanceCard({
    super.key,
    required this.fruitInfo,
    required this.ripeness,
  });

  final FruitInfo? fruitInfo;
  final Ripeness? ripeness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    final isDark = theme.brightness == Brightness.dark;
    final leafBg = isDark ? AppColors.dLeafSoft : AppColors.lLeafSoft;
    final leafFg = isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong;

    if (ripeness == Ripeness.rotten) {
      return IndustrialSpecimenCard(
        backgroundColor: harvest.rotten.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuidanceSection(
              icon: Icons.warning_amber_rounded,
              iconBg: harvest.rotten.withValues(alpha: 0.14),
              iconColor: harvest.rotten,
              title: AppStrings.rottenAdviceTitle,
              titleColor: harvest.rotten,
              body: AppStrings.rottenAdviceWarning,
            ),
            Divider(height: AppDimens.s24, color: harvest.border),
            _GuidanceSection(
              icon: Icons.recycling_rounded,
              iconBg: leafBg,
              iconColor: leafFg,
              title: AppStrings.rottenEcoTitle,
              body: AppStrings.rottenEcoBody,
            ),
          ],
        ),
      );
    }

    final (consumptionText, storageText) = _guidanceFor(ripeness, fruitInfo);
    return IndustrialSpecimenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuidanceSection(
            icon: Icons.schedule_rounded,
            iconBg: harvest.primarySoft,
            iconColor: ink,
            title: 'SARAN KONSUMSI',
            body: consumptionText,
          ),
          Divider(height: AppDimens.s24, color: harvest.border),
          _GuidanceSection(
            icon: Icons.hourglass_bottom_rounded,
            iconBg: leafBg,
            iconColor: leafFg,
            title: 'DAYA SIMPAN',
            body: storageText,
          ),
        ],
      ),
    );
  }

  (String, String) _guidanceFor(Ripeness? value, FruitInfo? info) {
    return switch (value) {
      Ripeness.unripe => (
        'Masih mentah dengan kandungan pati tinggi dan belum manis. '
            'Belum cocok dimakan langsung, namun pas diolah menjadi keripik '
            'atau pisang goreng.',
        'Simpan di suhu ruang selama 2–5 hari hingga kulit menguning merata. '
            'Jangan masukkan kulkas karena dapat menghambat proses pematangan.',
      ),
      Ripeness.overripe => (
        'Sangat matang dengan rasa manis maksimal dan tekstur lembut. '
            'Segera konsumsi atau olah menjadi smoothie, bolu pisang, atau '
            'pancake.',
        'Tahan sekitar 1 hari di suhu ruang. Kupas dan bekukan di freezer '
            'dalam wadah tertutup jika ingin disimpan lebih lama.',
      ),
      Ripeness.ripe || Ripeness.rotten || null => (
        info?.benefits ??
            'Sumber energi cepat, kalium, dan serat alami untuk aktivitas harian.',
        'Kondisi matang ideal untuk dinikmati langsung dalam 1–2 hari. '
            'Simpan di tempat sejuk dan jauhkan dari sinar matahari langsung.',
      ),
    };
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    this.titleColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppDimens.rButton),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: AppDimens.s8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ink.withValues(alpha: 0.85),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
