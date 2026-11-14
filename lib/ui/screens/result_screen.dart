import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_outcome.dart';
import '../../data/models/scan_report.dart';
import '../../providers/auth_providers.dart';
import '../../providers/chat_notifier.dart';
import '../../providers/scan_notifier.dart';
import '../widgets/app_card.dart';
import '../widgets/fruit_image.dart';
import '../widgets/nutrient_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/ripeness_chip.dart';
import '../widgets/rotten_guidance_sheet.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/soft_button.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isFavorite = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(AppDimens.s8),
          child: IconButton(
            onPressed: () {
              ref.read(scanProvider.notifier).reset();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: harvest.primarySoft,
              foregroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Hasil Pindai',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Analisis AI Selesai',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simpan Favorit',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? 'Ditambahkan ke favorit!'
                        : 'Dihapus dari favorit.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : harvest.muted,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimens.s8),
        ],
      ),
      body: state.when(
        loading: () => const _LoadingView(),
        error: (error, _) =>
            _ErrorView(message: error.toString(), onRetry: () => context.pop()),
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Belum ada hasil pindai.'));
          }
          final outcome = report.outcome;
          return switch (outcome) {
            ScanSuccess() => _SuccessView(
              report: report,
              outcome: outcome,
              isSaved: _isSaved,
              onSave: () async {
                setState(() => _isSaved = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tersimpan di riwayat!')),
                );
              },
            ),
            ScanUncertain() => _UncertainView(report: report),
            ScanFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.pop(),
            ),
          };
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppDimens.screenPadding),
      child: Column(
        children: [
          ShimmerBox(height: 180, radius: AppDimens.rHero),
          SizedBox(height: AppDimens.s16),
          ShimmerBox(height: 32, radius: AppDimens.s8),
          SizedBox(height: AppDimens.s16),
          Row(
            children: [
              Expanded(
                child: ShimmerBox(height: 72, radius: AppDimens.rButton),
              ),
              SizedBox(width: AppDimens.s12),
              Expanded(
                child: ShimmerBox(height: 72, radius: AppDimens.rButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UncertainView extends StatelessWidget {
  const _UncertainView({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        FruitImage(
          imagePath: report.imagePath,
          height: 160,
          radius: AppDimens.rHero,
        ),
        const SizedBox(height: AppDimens.s16),
        AppCard(
          child: Column(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 44,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppDimens.s12),
              Text(
                AppStrings.resultUncertainTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                AppStrings.resultUncertainBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s20),
        PrimaryButton(
          text: AppStrings.resultRetake,
          icon: Icons.refresh_rounded,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              AppStrings.resultErrorTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              message.isNotEmpty ? message : AppStrings.resultErrorBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.s20),
            PrimaryButton(
              text: AppStrings.resultRetry,
              onPressed: onRetry,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView({
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

    final isLowConfidence =
        outcome.fruitConfidence < 0.6 || outcome.ripenessConfidence < 0.6;
    final hasAllergy = _checkFruitAllergy(
      outcome.fruitLabel,
      userProfile?.allergies,
    );

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        // 1. Foto Buah (Hero card dengan radius 22)
        FruitImage(
          imagePath: report.imagePath,
          fruitLabel: outcome.fruitLabel,
          height: 180,
          radius: AppDimens.rHero,
        ),
        const SizedBox(height: AppDimens.s16),

        // 2. Baris Judul & Status Kematangan
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
                  const SizedBox(height: AppDimens.s4),
                  if (ripeness != null) RipenessChip(ripeness: ripeness),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(outcome.ripenessConfidence * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: ripeness != null
                        ? harvest.forRipeness(ripeness)
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Akurasi Kematangan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s16),

        // Peringatan jika keyakinan rendah (<60%)
        if (isLowConfidence) ...[
          AppCard(
            color: harvest.overripe.withValues(alpha: 0.12),
            borderColor: harvest.overripe,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: harvest.overripe),
                const SizedBox(width: AppDimens.s8),
                Expanded(
                  child: Text(
                    'Tingkat keyakinan rendah (<60%). Pastikan pencahayaan terang dan ambil foto lebih dekat.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: harvest.overripe,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),
        ],

        // 2b. Rincian Probabilitas Kelas SVM (3 kelas / 4 kelas sesuai respons model)
        if (outcome.classProbabilities != null &&
            outcome.classProbabilities!.isNotEmpty) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: Text(
                        'Rincian Probabilitas ${outcome.classProbabilities!.length} Kelas SVM',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s12),
                ..._orderedProbabilities(outcome.classProbabilities!).map((
                  entry,
                ) {
                  final rawClass = entry.key;
                  final prob = entry.value;
                  final rip = Ripeness.fromLabel(rawClass);
                  final barColor = rip != null
                      ? harvest.forRipeness(rip)
                      : theme.colorScheme.primary;

                  final labelIndo = switch (rawClass) {
                    'unripe' => 'Mentah (Unripe)',
                    'ripe' => 'Matang (Ripe)',
                    'overripe' => 'Terlalu Matang (Overripe)',
                    'rotten' => 'Busuk (Rotten)',
                    _ => rawClass,
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.s8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                labelIndo,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${(prob * 100).toStringAsFixed(1)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.rPill),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: prob.clamp(0.0, 1.0),
                            ),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedValue, _) {
                              return LinearProgressIndicator(
                                value: animatedValue,
                                minHeight: 8,
                                backgroundColor: barColor.withValues(
                                  alpha: 0.15,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  barColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s16),
        ],

        // 3. Tombol Aksi Cepat: Tanya AI & Ide Resep / Tips Pengolahan
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Tanya AI',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () {
                  final contextStr = '$fruitTitle (${outcome.ripenessLabel})';
                  ref
                      .read(chatNotifierProvider.notifier)
                      .setScanContext(contextStr);
                  context.go('/chat');
                },
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: SoftButton(
                text: ripeness == Ripeness.rotten
                    ? AppStrings.rottenRecycleButton
                    : 'Ide Resep',
                icon: ripeness == Ripeness.rotten
                    ? Icons.compost_rounded
                    : Icons.menu_book_rounded,
                onPressed: () {
                  if (ripeness == Ripeness.rotten) {
                    showRottenGuidanceSheet(context, fruitTitle);
                  } else {
                    context.push(
                      '/recipes?fruit=${outcome.fruitLabel}&ripeness=${outcome.ripenessLabel}',
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s16),

        // 4. Banner Kalori Segar (Fresh Harvest Banner sesuai tampilan yang disukai user)
        if (info != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s16,
              vertical: AppDimens.s12,
            ),
            decoration: BoxDecoration(
              color: harvest.primarySoft,
              borderRadius: BorderRadius.circular(AppDimens.rCard),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                width: 1,
              ),
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
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      'kkal · Kalori',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                  child: Text(
                    'Per 100 g',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: harvest.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),

          // 5. Metrik Komposisi Gizi (Karbohidrat, Gula Alami, Serat)
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
          const SizedBox(height: AppDimens.s16),
        ],

        // 6. Kartu Analisis Kematangan & Rekomendasi Konsumsi
        if (ripeness != null) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 20,
                      color: harvest.forRipeness(ripeness),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      'Analisis Kematangan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  _getRipenessDescription(fruitTitle, ripeness),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),
        ],

        // 7. Kartu Manfaat & Nutrisi Esensial
        if (info != null) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      AppStrings.resultBenefits,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.s8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: harvest.primarySoft,
                        borderRadius: BorderRadius.circular(AppDimens.rPill),
                      ),
                      child: Text(
                        info.vitamins,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  info.benefits,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),

          // 8. Kartu Cara Menyimpan & Ketahanan Simpan
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.kitchen_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      'Cara Menyimpan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  info.storageTips,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s16),
        ],

        // 9. Kartu Peringatan Alergi
        if (hasAllergy != null) ...[
          AppCard(
            color: theme.colorScheme.error.withValues(alpha: 0.08),
            borderColor: theme.colorScheme.error,
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: theme.colorScheme.error),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Text(
                    'Perhatian: Buah ini cocok dengan riwayat alergi profil Anda ($hasAllergy). Harap berhati-hati saat mengonsumsi.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s16),
        ],

        // 10. Tombol Simpan ke Riwayat
        PrimaryButton(
          text: isSaved ? 'Tersimpan di Riwayat ✓' : 'Simpan ke Riwayat',
          icon: isSaved
              ? Icons.check_circle_rounded
              : Icons.bookmark_add_outlined,
          onPressed: isSaved ? null : onSave,
        ),
        const SizedBox(height: AppDimens.s24),
      ],
    );
  }

  static String _getRipenessDescription(String fruit, Ripeness ripeness) {
    return switch (ripeness) {
      Ripeness.unripe =>
        'Masih dalam fase mengkal/mentah. Tekstur cenderung padat dengan rasa sedikit asam atau kelat. Simpan 2–3 hari di suhu ruang agar matang alami.',
      Ripeness.ripe =>
        'Kondisi matang sempurna dengan rasa manis seimbang dan aroma harum. Sangat nikmat dikonsumsi langsung atau dicampur ke salad buah.',
      Ripeness.overripe =>
        'Tingkat kematangan sangat tinggi dengan tekstur sangat lembut dan kadar gula alami maksimal. Paling pas diolah menjadi smoothie, puding, atau kue.',
      Ripeness.rotten => AppStrings.rottenAdviceWarning,
    };
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
      'watermelon' => ['semangka', 'watermelon'],
      'strawberry' => ['stroberi', 'strawberry', 'beri'],
      'pineapple' => ['nanas', 'pineapple'],
      'papaya' => ['pepaya', 'papaya'],
      'grape' => ['anggur', 'grape'],
      'tomato' => ['tomat', 'tomato'],
      _ => [lowerFruit],
    };

    for (final alias in aliases) {
      for (final a in lowerAllergies) {
        if (a.contains(alias)) return alias;
      }
    }
    return null;
  }

  List<MapEntry<String, double>> _orderedProbabilities(
    Map<String, double> probabilities,
  ) {
    const order = <String>['unripe', 'ripe', 'overripe', 'rotten'];
    final entries = probabilities.entries.toList();
    entries.sort((a, b) {
      final idxA = order.indexOf(a.key);
      final idxB = order.indexOf(b.key);
      final rankA = idxA == -1 ? order.length : idxA;
      final rankB = idxB == -1 ? order.length : idxB;
      return rankA.compareTo(rankB);
    });
    return entries;
  }
}
