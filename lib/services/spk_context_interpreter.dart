import 'spk_decision_service.dart';

/// How well the user's chosen timeframe & usage goal fit the banana's ripeness.
enum SpkSuitability {
  ideal('Sangat Cocok'),
  adjust('Perlu Penyesuaian'),
  notRecommended('Tidak Disarankan');

  const SpkSuitability(this.labelId);
  final String labelId;
}

/// Human-friendly contextual interpretation built on top of the PSO-RF decision.
class SpkContextualAdvice {
  const SpkContextualAdvice({
    required this.suitability,
    required this.headline,
    required this.reason,
    required this.actionTip,
  });

  final SpkSuitability suitability;
  final String headline;
  final String reason;
  final String actionTip;
}

/// Translates the 4-class PSO-Random Forest output + banana ripeness + user's
/// selected timeframe (`targetDays`) and goal (`usageGoal`) into specific,
/// easy-to-understand Indonesian guidance so every button tap gives distinct,
/// actionable feedback without modifying the trained `spk_pso_rf_model.json`.
abstract final class SpkContextInterpreter {
  static SpkContextualAdvice interpret({
    required String ripenessLabel,
    required SpkTargetDays targetDays,
    required SpkUsageGoal usageGoal,
    required SpkDecisionClass baseDecision,
  }) {
    final ripeness = ripenessLabel.trim().toLowerCase();

    if (ripeness == 'rotten' || baseDecision.id == 3) {
      return const SpkContextualAdvice(
        suitability: SpkSuitability.notRecommended,
        headline: 'Jangan Dikonsumsi — Alihkan ke Kompos',
        reason:
            'Indikasi pembusukan sudah dominan dan berisiko mengandung jamur '
            'atau bakteri yang tidak aman bagi pencernaan.',
        actionTip:
            'Segera pisahkan dari buah sehat agar gas etilen dan jamur tidak '
            'menular, lalu manfaatkan sebagai pupuk kompos organik.',
      );
    }

    if (ripeness == 'unripe') {
      return _forUnripe(targetDays, usageGoal);
    }

    if (ripeness == 'overripe' || ripeness == 'very_ripe') {
      return _forOverripe(targetDays, usageGoal);
    }

    return _forRipe(targetDays, usageGoal);
  }

  static SpkContextualAdvice _forUnripe(SpkTargetDays days, SpkUsageGoal goal) {
    if (goal == SpkUsageGoal.culinaryProcessing) {
      return switch (days) {
        SpkTargetDays.today => const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Siap Diolah Hari Ini (Keripik / Gorengan)',
          reason:
              'Tekstur padat dan pati tinggi pada pisang mentah paling cocok '
              'untuk keripik pisang, pisang goreng tipis, atau pisang rebus.',
          actionTip:
              'Rendam irisan pisang dalam air garam tipis 5 menit untuk '
              'menghilangkan getah agar hasil olahan lebih renyah.',
        ),
        SpkTargetDays.twoToThreeDays => const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Simpan Suhu Ruang, Olah 2–3 Hari Lagi',
          reason:
              'Dalam 2–3 hari pisang masuk fase mengkal (semi-matang) yang '
              'tetap kokoh namun lebih manis untuk kolak atau pisang bakar.',
          actionTip:
              'Simpan di tempat teduh suhu ruang; hindari kulkas karena suhu '
              'dingin dapat menghambat pematangan dan menggelapkan kulit.',
        ),
        SpkTargetDays.moreThanFourDays => const SpkContextualAdvice(
          suitability: SpkSuitability.adjust,
          headline: 'Akan Matang Penuh dalam > 4 Hari',
          reason:
              'Jika menunggu > 4 hari, pisang tidak lagi mentah melainkan '
              'matang penuh—lebih pas nanti untuk bolu atau smoothie, bukan keripik.',
          actionTip:
              'Simpan di suhu ruang sejuk (20–25°C) dan pantau warna kulit '
              'tiap hari agar bisa diolah tepat saat kematangan yang diinginkan.',
        ),
      };
    }

    // Retail / distribution (or fallback) for unripe
    return switch (days) {
      SpkTargetDays.moreThanFourDays => const SpkContextualAdvice(
        suitability: SpkSuitability.ideal,
        headline: 'Ideal untuk Stok Jual & Pengiriman',
        reason:
            'Pisang masih mentah optimal, tahan 4–5 hari di suhu ruang, dan '
            'kulitnya kuat terhadap benturan selama distribusi jarak jauh.',
        actionTip:
            'Simpan di ruang sejuk (20–25°C) bersirkulasi udara baik dan '
            'hindari membungkus rapat dalam plastik.',
      ),
      SpkTargetDays.twoToThreeDays => const SpkContextualAdvice(
        suitability: SpkSuitability.adjust,
        headline: 'Peram Dulu agar Matang Pas Saat Dijual',
        reason:
            'Pisang masih terlalu hijau untuk dipajang 2–3 hari lagi tanpa '
            'bantuan pemeraman alami.',
        actionTip:
            'Simpan di kardus/kertas tertutup bersama 1 pisang matang atau '
            'apel agar proses pematangan lebih cepat dan merata.',
      ),
      SpkTargetDays.today => const SpkContextualAdvice(
        suitability: SpkSuitability.notRecommended,
        headline: 'Belum Siap Pajang Retail Hari Ini',
        reason:
            'Pisang masih hijau dan sepat sehingga kurang diminati pembeli '
            'konsumsi langsung hari ini.',
        actionTip:
            'Tawarkan khusus ke pembeli grosir/pengolah keripik, atau tahan '
            'dulu 3–4 hari hingga kulit mulai menguning.',
      ),
    };
  }

  static SpkContextualAdvice _forRipe(SpkTargetDays days, SpkUsageGoal goal) {
    return switch ((days, goal)) {
      (SpkTargetDays.today, SpkUsageGoal.freshConsumption) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Siap Dimakan Langsung Hari Ini',
          reason:
              'Rasa manis alami, aroma harum, dan tekstur lembut sedang di '
              'titik puncak. Paling nikmat dinikmati segar sekarang.',
          actionTip:
              'Nikmati langsung sebagai sumber energi cepat atau padukan '
              'dengan oatmeal, yogurt, atau roti panggang.',
        ),
      (SpkTargetDays.today, SpkUsageGoal.retailDistribution) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Siap Pajang di Etalase Hari Ini',
          reason:
              'Warna kuning cerah dan kulit mulus memiliki daya tarik visual '
              'tertinggi untuk penjualan harian di etalase.',
          actionTip:
              'Gantung tandan pisang agar kulit tidak memar dan targetkan '
              'habis terjual dalam 1–2 hari ke depan.',
        ),
      (SpkTargetDays.today, SpkUsageGoal.culinaryProcessing) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Pas untuk Olahan Segar & Dessert',
          reason:
              'Pisang matang memberi manis alami yang seimbang dan tekstur '
              'tidak terlalu lembek untuk smoothie, pancake, atau pisang bakar.',
          actionTip:
              'Buka Rekomendasi Resep di bawah untuk melihat pilihan menu '
              'praktis yang paling cocok dengan pisang matang.',
        ),
      (SpkTargetDays.twoToThreeDays, SpkUsageGoal.freshConsumption) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.adjust,
          headline: 'Perlambat Pematangan agar Tahan 2–3 Hari',
          reason:
              'Di suhu ruang, pisang matang hanya bertahan 1–2 hari sebelum '
              'muncul bintik cokelat dan teksturnya melunak.',
          actionTip:
              'Bungkus tangkai dengan plastik wrap dan simpan di rak kulkas '
              '(kulit bisa agak gelap, tapi daging buah tetap manis dan segar).',
        ),
      (SpkTargetDays.twoToThreeDays, SpkUsageGoal.retailDistribution) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.adjust,
          headline: 'Batas Aman Etalase Maksimal 2 Hari',
          reason:
              'Memasuki hari ke-3, pisang matang mulai berbintik cokelat yang '
              'dapat menurunkan minat beli di etalase segar.',
          actionTip:
              'Taruh di rak paling depan (FIFO), jaga suhu ruang sejuk '
              '(15–18°C), dan pisahkan dari buah penghasil etilen.',
        ),
      (SpkTargetDays.twoToThreeDays, SpkUsageGoal.culinaryProcessing) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Makin Manis untuk Kue & Smoothie',
          reason:
              'Dalam 2–3 hari pisang masuk fase sangat matang dengan kadar '
              'gula lebih tinggi—justru lebih sedap untuk bolu atau milkshake.',
          actionTip:
              'Simpan di suhu ruang teduh hingga muncul bintik manis, lalu '
              'segera olah sebelum kulit menghitam penuh.',
        ),
      (SpkTargetDays.moreThanFourDays, SpkUsageGoal.freshConsumption) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.notRecommended,
          headline: 'Tidak Kuat > 4 Hari — Bekukan Sekarang',
          reason:
              'Pisang matang akan terlalu lembek bahkan mulai busuk jika '
              'dibiarkan > 4 hari di suhu ruang.',
          actionTip:
              'Kupas, potong-potong, dan simpan dalam wadah kedap udara di '
              'freezer agar awet 1–2 bulan untuk smoothie atau es krim.',
        ),
      (SpkTargetDays.moreThanFourDays, SpkUsageGoal.retailDistribution) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.notRecommended,
          headline: 'Risiko Rugi jika Disimpan > 4 Hari',
          reason:
              'Daya tahan jual segar pisang matang tidak sampai 4 hari. '
              'Menyimpannya terlalu lama berisiko busuk sebelum laku.',
          actionTip:
              'Jual cepat hari ini (promo/diskon) atau alihkan menjadi produk '
              'olahan bernilai tambah seperti bolu, sale, atau es pisang.',
        ),
      (SpkTargetDays.moreThanFourDays, SpkUsageGoal.culinaryProcessing) =>
        const SpkContextualAdvice(
          suitability: SpkSuitability.adjust,
          headline: 'Olah Sekarang atau Bekukan untuk Nanti',
          reason:
              'Jika dibiarkan > 4 hari di suhu ruang, pisang akan melewati '
              'batas layak olah dan mulai terfermentasi.',
          actionTip:
              'Bekukan daging pisang di freezer hari ini, atau langsung olah '
              'sekarang memakai ide resep di bawah.',
        ),
    };
  }

  static SpkContextualAdvice _forOverripe(
    SpkTargetDays days,
    SpkUsageGoal goal,
  ) {
    if (goal == SpkUsageGoal.culinaryProcessing) {
      return switch (days) {
        SpkTargetDays.today => const SpkContextualAdvice(
          suitability: SpkSuitability.ideal,
          headline: 'Waktu Terbaik untuk Kue & Smoothie',
          reason:
              'Kadar gula alami maksimal pada pisang matang banget membuat '
              'banana bread, pancake, dan smoothie manis tanpa banyak gula.',
          actionTip:
              'Langsung haluskan untuk adonan kue atau blender bersama susu '
              'dan oat. Ketuk Rekomendasi Resep di bawah!',
        ),
        _ => const SpkContextualAdvice(
          suitability: SpkSuitability.adjust,
          headline: 'Bekukan Dulu jika Diolah 2–3 Hari Lagi',
          reason:
              'Pisang sangat matang tidak kuat disimpan di suhu ruang 2–3 hari '
              'tanpa risiko berjamur atau berbau asam.',
          actionTip:
              'Kupas, potong, dan bekukan di freezer sekarang—pisang beku '
              'justru menghasilkan tekstur smoothie dan bolu yang lebih lembut.',
        ),
      };
    }

    // Fresh consumption for overripe
    return switch (days) {
      SpkTargetDays.today => const SpkContextualAdvice(
        suitability: SpkSuitability.adjust,
        headline: 'Segera Habiskan Hari Ini',
        reason:
            'Rasa sangat manis dan tekstur sudah sangat lunak. Masih aman '
            'dimakan langsung hari ini selama tidak berbau asam atau berjamur.',
        actionTip:
            'Potong bagian yang terlalu memar jika ada dan nikmati hari ini; '
            'jangan tunda hingga besok.',
      ),
      _ => const SpkContextualAdvice(
        suitability: SpkSuitability.notRecommended,
        headline: 'Tidak Tahan 2–3 Hari di Suhu Ruang',
        reason:
            'Pisang sangat matang akan cepat terfermentasi dan membusuk dalam '
            'waktu 24 jam jika dibiarkan di suhu ruang.',
        actionTip:
            'Jika belum sempat dimakan hari ini, segera kupas dan masukkan '
            'freezer agar tetap aman dijadikan smoothie nanti.',
      ),
    };
  }
}
