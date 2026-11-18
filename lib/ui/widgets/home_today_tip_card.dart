import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'app_card.dart';
import 'fruit_vector_icon.dart';

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
                            tip.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
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
                      foregroundColor: theme.colorScheme.onPrimary,
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

    final dayIndex = DateTime.now().weekday % tipsList.length;
    final tip = tipsList[dayIndex];

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
              onTap: () => showTipDialog(context, tip),
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
