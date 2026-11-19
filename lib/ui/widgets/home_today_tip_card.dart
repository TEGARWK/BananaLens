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
      title: 'Pisang Berbintik Hitam',
      shortText:
          'Bintik hitam justru menandakan kadar antioksidan dan rasa manis alami tertinggi.',
      fullText:
          'Bintik hitam pada kulit pisang menandakan produksi Tumor Necrosis Factor (TNF) dan antioksidan yang optimal. Sangat manis alami, mudah dicerna, dan sempurna untuk bahan smoothie atau pancake sehat tanpa tambahan gula.',
      fruit: 'banana',
    ),
    FruitTipItem(
      title: 'Cara Menyimpan Apel',
      shortText:
          'Simpan apel di kulkas dan jauhkan dari buah sensitif agar tidak cepat layu.',
      fullText:
          'Apel melepaskan gas etilen dalam jumlah tinggi yang mempercepat pematangan buah lain di sekitarnya. Simpan di laci bawah kulkas dengan kantong berpori agar kesegarannya bertahan hingga sebulan.',
      fruit: 'apple',
    ),
    FruitTipItem(
      title: 'Alpukat Matang Sempurna',
      shortText:
          'Tekan lembut pangkal tangkai alpukat untuk memastikan kematangan tanpa merusak dagingnya.',
      fullText:
          'Jika tangkai kecil di atas mudah lepas dan memperlihatkan warna hijau muda di bawahnya, alpukat siap dinikmati! Mengandung asam lemak tak jenuh tunggal yang sangat baik bagi kesehatan jantung.',
      fruit: 'avocado',
    ),
    FruitTipItem(
      title: 'Aroma Khas Mangga Matang',
      shortText:
          'Aroma harum manis di bagian pangkal buah menandakan mangga sudah matang alami di pohon.',
      fullText:
          'Hindari memilih mangga yang pangkalnya masih keras dan tidak beraroma. Mangga matang pohon kaya akan vitamin A dan enzim alami yang baik untuk kesehatan mata serta membantu metabolisme pencernaan.',
      fruit: 'mango',
    ),
    FruitTipItem(
      title: 'Menjaga Kesegaran Jeruk',
      shortText:
          'Simpan jeruk dalam kondisi utuh di wadah terbuka pada suhu ruang sejuk atau kulkas.',
      fullText:
          'Jeruk yang disimpan utuh dapat bertahan hingga 2-3 minggu di laci kulkas. Jangan mengupas kulitnya sebelum hendak disantap agar kandungan vitamin C dan antioksidan alami tidak teroksidasi oleh udara bebas.',
      fruit: 'orange',
    ),
    FruitTipItem(
      title: 'Semangka Manis & Berair',
      shortText:
          'Cari bercak kuning krem di kulit bawah semangka sebagai tanda matang sempurna di kebun.',
      fullText:
          'Bercak field spot yang berwarna krem kekuningan menandakan semangka matang sempurna sebelum dipetik. Semangka mengandung 92% air dan likopen tinggi yang sangat efektif untuk rehidrasi tubuh dan mencegah radikal bebas.',
      fruit: 'watermelon',
    ),
    FruitTipItem(
      title: 'Menyimpan Buah Potong',
      shortText:
          'Beri sedikit perasan lemon atau simpan dalam wadah kedap udara agar tidak cepat mencokelat.',
      fullText:
          'Asam sitrat alami pada air lemon memperlambat enzim polifenol oksidase yang menyebabkan pencokelatan (browning). Selalu simpan buah potong di kulkas dan habiskan dalam 24-48 jam untuk nutrisi optimal.',
      fruit: 'pineapple',
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
                                  'Tips Kesehatan FruitLens',
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ink.withValues(alpha: 0.8),
                        height: 1.35,
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
