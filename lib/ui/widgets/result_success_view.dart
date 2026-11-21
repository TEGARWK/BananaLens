import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/fruit_info.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_outcome.dart';
import '../../data/models/scan_report.dart';
import '../../providers/auth_providers.dart';
import '../../providers/chat_notifier.dart';
import 'fruit_image.dart';
import 'industrial_art.dart';
import 'nutrient_tile.dart';
import 'primary_button.dart';
import 'result_probability_accordion.dart';
import 'result_recipe_gating_section.dart';
import 'ripeness_chip.dart';
import 'soft_button.dart';

/// Streamlined 4-block post-scan report:
/// 1. Hero status + collapsible AI score breakdown
/// 2. Interactive SPK decision & action card
/// 3. Compact nutrition & benefits summary
/// 4. Secondary actions (Save to History + Ask AI)
class ResultSuccessView extends ConsumerWidget {
  const ResultSuccessView({
    super.key,
    required this.report,
    required this.outcome,
    required this.isSaved,
    required this.onSave,
  });

  final ScanReport report;
  final ScanSuccess outcome;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final info = report.fruitInfo;
    final ripeness = Ripeness.fromLabel(outcome.ripenessLabel);
    final fruitTitle = info?.nameId ?? outcome.fruitLabel;
    final userProfile = ref.watch(authNotifierProvider).value;

    final isLowConfidence = outcome.ripenessConfidence < kConfidenceThreshold;
    final hasAllergy = _checkFruitAllergy(
      outcome.fruitLabel,
      userProfile?.allergies,
    );
    final ink = theme.colorScheme.onSurface;
    final (accBg, accFg) = switch (ripeness) {
      Ripeness.unripe => (const Color(0xFF3E7D28), Colors.white),
      Ripeness.rotten => (const Color(0xFFC43E2B), Colors.white),
      _ => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
    };

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        // 1. Ringkasan Hasil Pindai (Foto + Status + Akurasi)
        _buildHeroCard(theme, harvest, ink, fruitTitle, ripeness, accBg, accFg),
        const SizedBox(height: AppDimens.s12),

        if (isLowConfidence) ...[
          _buildLowConfidenceBanner(theme, ink),
          const SizedBox(height: AppDimens.s12),
        ],

        if (outcome.classProbabilities != null &&
            outcome.classProbabilities!.isNotEmpty) ...[
          ResultProbabilityAccordion(
            probabilities: outcome.classProbabilities!,
          ),
          const SizedBox(height: AppDimens.s16),
        ] else
          const SizedBox(height: AppDimens.s4),

        // 2. Rekomendasi Tindakan SPK (Hero Action)
        ResultRecipeGatingSection(outcome: outcome),

        // 3. Info Gizi & Manfaat Ringkas
        if (info != null) ...[
          _buildNutritionSection(theme, harvest, ink, info),
          const SizedBox(height: AppDimens.s16),
        ],

        // Peringatan Alergi jika relevan dengan profil pengguna
        if (hasAllergy != null) ...[
          _buildAllergyBanner(theme, hasAllergy),
          const SizedBox(height: AppDimens.s16),
        ],

        // 4. Aksi Lanjutan: Simpan ke Riwayat & Tanya AI
        Row(
          children: [
            Expanded(
              flex: 3,
              child: PrimaryButton(
                text: isSaved ? 'Tersimpan' : 'Simpan ke Riwayat',
                icon: isSaved
                    ? Icons.check_circle_rounded
                    : Icons.bookmark_add_outlined,
                onPressed: isSaved ? null : onSave,
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              flex: 2,
              child: SoftButton(
                text: 'Tanya AI',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () {
                  final ripenessIndo =
                      ripeness?.labelId ?? outcome.ripenessLabel;
                  final pct = (outcome.ripenessConfidence * 100).round();
                  final contextStr =
                      '$fruitTitle ($ripenessIndo · $pct% keyakinan)';
                  ref
                      .read(chatNotifierProvider.notifier)
                      .openWithScanContext(contextStr);
                  context.go('/chat');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s24),
      ],
    );
  }

  Widget _buildHeroCard(
    ThemeData theme,
    HarvestColors harvest,
    Color ink,
    String fruitTitle,
    Ripeness? ripeness,
    Color accBg,
    Color accFg,
  ) {
    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const IndustrialTagChip(label: 'HASIL // PINDAI', accent: true),
              Text(
                'BANANALENS AI',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              border: Border.all(color: ink, width: 1.5),
            ),
            child: FruitImage(
              imagePath: report.imagePath,
              fruitLabel: outcome.fruitLabel,
              height: 168,
              radius: AppDimens.rButton - 1,
            ),
          ),
          const SizedBox(height: AppDimens.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fruitTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    if (ripeness != null) RipenessChip(ripeness: ripeness),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: AppDimens.s8,
                ),
                decoration: BoxDecoration(
                  color: accBg,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: ink, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ink,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(outcome.ripenessConfidence * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: accFg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Akurasi Kematangan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowConfidenceBanner(ThemeData theme, Color ink) {
    return IndustrialSpecimenCard(
      backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.14),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: AppDimens.s8),
          Expanded(
            child: Text(
              'Hasil foto kurang jelas (<60%). Coba foto ulang di tempat terang dan jarak lebih dekat ya.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(
    ThemeData theme,
    HarvestColors harvest,
    Color ink,
    FruitInfo info,
  ) {
    return Column(
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
            border: Border.all(color: ink, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: ink,
                offset: const Offset(2, 2.5),
                blurRadius: 0,
              ),
            ],
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
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.2),
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
        const SizedBox(height: AppDimens.s12),
        IndustrialSpecimenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      border: Border.all(color: ink, width: 1.2),
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      size: 16,
                      color: ink,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Text(
                    AppStrings.resultBenefits,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: harvest.primarySoft,
                          borderRadius: BorderRadius.circular(AppDimens.rSharp),
                          border: Border.all(color: ink, width: 1),
                        ),
                        child: Text(
                          info.vitamins,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                info.benefits,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ink.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllergyBanner(ThemeData theme, String hasAllergy) {
    return IndustrialSpecimenCard(
      backgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: theme.colorScheme.error),
          const SizedBox(width: AppDimens.s12),
          Expanded(
            child: Text(
              'Perhatian: Buah ini cocok dengan riwayat alergi profil Anda ($hasAllergy). Harap berhati-hati saat mengonsumsi.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _checkFruitAllergy(String fruitLabel, List<String>? allergies) {
    if (allergies == null || allergies.isEmpty) return null;
    final lowerFruit = fruitLabel.toLowerCase();
    final lowerAllergies = allergies.map((e) => e.toLowerCase()).toList();
    final aliases = switch (lowerFruit) {
      'banana' => ['pisang', 'banana'],
      'apple' => ['apel', 'apple'],
      'avocado' => ['alpukat', 'avocado'],
      'orange' => ['jeruk', 'orange', 'citrus'],
      'mango' => ['mangga', 'mango'],
      _ => [lowerFruit],
    };
    for (final alias in aliases) {
      for (final a in lowerAllergies) {
        if (a.contains(alias)) return alias;
      }
    }
    return null;
  }
}
