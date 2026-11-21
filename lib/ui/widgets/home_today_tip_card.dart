import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'fruit_vector_icon.dart';
import 'industrial_art.dart';
import 'primary_button.dart';

/// Item data for a daily fruit storage and wellness tip.
class FruitTipItem {
  const FruitTipItem({
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

/// Card showing the tip of the day with a bottom sheet reader.
class HomeTodayTipCard extends StatelessWidget {
  const HomeTodayTipCard({super.key});

  static const List<FruitTipItem> tipsList = [
    FruitTipItem(
      title: 'Pisang Berbintik Cokelat',
      shortText:
          'Bintik cokelat kecil menandakan kadar gula alami dan antioksidan pisang sedang tinggi.',
      fullText:
          'Bintik cokelat kecil (sugar spots) pada kulit pisang kuning menandakan pisang sudah sangat matang dan manis alami. Dagingnya tetap bagus, mudah dicerna, dan cocok dijadikan smoothie, pancake, atau banana bread tanpa banyak gula tambahan.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Bungkus Tangkai Pisang',
      shortText:
          'Membungkus pangkal tangkai pisang membantu memperlambat pematangan agar tidak cepat hitam.',
      fullText:
          'Gas etilen paling banyak keluar dari pangkal tangkai pisang. Bungkus rapat bagian tangkai dengan plastik wrap atau kertas aluminium, lalu gantung di suhu ruang sejuk agar pisang matang 2-3 hari lebih awet.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Manfaat Pisang Mentah',
      shortText:
          'Pisang hijau kaya pati resisten yang baik untuk pencernaan setelah dimasak matang.',
      fullText:
          'Pisang mentah (hijau) memiliki kadar gula lebih rendah dan tinggi pati resisten sebagai prebiotik alami. Sebaiknya jangan dimakan mentah langsung; rebus dengan sedikit garam atau olah menjadi keripik pisang renyah.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Mematangkan Pisang Lebih Cepat',
      shortText:
          'Simpan pisang hijau dalam kantong kertas tertutup di suhu ruang selama 1-2 hari.',
      fullText:
          'Jika kamu membeli pisang mentah dan ingin segera dinikmati, masukkan ke dalam kantong kertas cokelat yang dilipat longgar. Gas etilen alami akan terperangkap di dalamnya sehingga proses pematangan lebih cepat dan merata.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Bekukan Pisang Sebelum Busuk',
      shortText:
          'Kupas dan potong pisang yang terlalu matang lalu bekukan untuk stok smoothie harian.',
      fullText:
          'Jangan buang pisang yang kulitnya mulai sangat berbintik jika dagingnya masih padat dan tidak berbau asam. Kupas, potong-potong, simpan dalam wadah kedap udara di freezer—tahan hingga 2 bulan dan siap diblender kapan saja.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Kenali Tanda Pisang Busuk',
      shortText:
          'Kulit menghitam berair, daging sangat lembek, atau muncul bau fermentasi menandakan busuk.',
      fullText:
          'Pisang yang sudah busuk ditandai bau asam menyengat, cairan merembes dari kulit, atau adanya bercak jamur. Hindari mengonsumsinya dan manfaatkan sebagai bahan kompos organik untuk tanaman.',
      fruit: 'banana',
    ),
  ];

  /// Shows the full article modal bottom sheet for a given [FruitTipItem].
  static void showTipDialog(BuildContext context, FruitTipItem tip) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    margin: const EdgeInsets.only(bottom: AppDimens.s16),
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const IndustrialTagChip(
                      label: 'TIPS // HARIAN',
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
                IndustrialSpecimenCard(
                  padding: const EdgeInsets.all(AppDimens.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FruitVectorIcon(
                            fruitLabel: tip.fruit,
                            size: 44,
                            isCircular: false,
                          ),
                          const SizedBox(width: AppDimens.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Tips Kesehatan BananaLens',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: harvest.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.s12),
                      Divider(height: 1, color: harvest.border),
                      const SizedBox(height: AppDimens.s12),
                      Text(
                        tip.fullText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ink.withValues(alpha: 0.88),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s20),
                PrimaryButton(
                  text: 'Tutup Tips',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(ctx).pop(),
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
    final ink = theme.colorScheme.onSurface;

    final dayIndex = DateTime.now().weekday % tipsList.length;
    final tip = tipsList[dayIndex];

    return IndustrialSpecimenCard(
      backgroundColor: harvest.primarySoft,
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
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.3),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.onPrimary,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      tip.shortText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ink.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => showTipDialog(context, tip),
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Baca selengkapnya',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: ink),
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
