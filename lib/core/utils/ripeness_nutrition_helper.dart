import '../../data/models/fruit_info.dart';
import '../../data/models/ripeness.dart';

/// Adjusts per-100g nutrition estimates based on fruit ripeness stage.
///
/// During banana ripening, amylase breaks down resistant starch into simple
/// sugars (glucose, fructose, sucrose), increasing natural sugar while
/// lowering dietary fiber and slightly raising caloric density per 100g.
abstract final class RipenessNutritionHelper {
  /// Returns an adjusted [FruitInfo] reflecting the given [ripeness] stage.
  /// Returns `null` when [ripeness] is [Ripeness.rotten] because spoiled fruit
  /// is unsafe to consume and edible nutrition metrics do not apply.
  static FruitInfo? adjust(FruitInfo info, Ripeness? ripeness) {
    if (ripeness == Ripeness.rotten) return null;
    if (ripeness == null || ripeness == Ripeness.ripe) return info;

    final isBanana = info.label.trim().toLowerCase() == 'banana';
    if (isBanana) {
      return switch (ripeness) {
        Ripeness.unripe => FruitInfo(
          label: info.label,
          nameId: info.nameId,
          calories: 82,
          carbs: 21.5,
          sugar: 3.5,
          fiber: 3.8,
          vitamins: info.vitamins,
          benefits:
              'Kaya pati resisten (prebiotik alami) yang baik untuk kesehatan '
              'pencernaan dan membantu menjaga gula darah tetap stabil.',
          storageTips: info.storageTips,
          allergenNote: info.allergenNote,
        ),
        Ripeness.overripe => FruitInfo(
          label: info.label,
          nameId: info.nameId,
          calories: 96,
          carbs: 24.5,
          sugar: 16.5,
          fiber: 1.8,
          vitamins: info.vitamins,
          benefits:
              'Kadar gula alami dan antioksidan meningkat; sumber energi cepat '
              'yang sangat mudah dicerna serta ideal untuk olahan sehat.',
          storageTips: info.storageTips,
          allergenNote: info.allergenNote,
        ),
        Ripeness.ripe || Ripeness.rotten => info,
      };
    }

    // Proportional fallback for non-banana fruits.
    return switch (ripeness) {
      Ripeness.unripe => FruitInfo(
        label: info.label,
        nameId: info.nameId,
        calories: _round1(info.calories * 0.92),
        carbs: _round1(info.carbs * 0.94),
        sugar: _round1(info.sugar * 0.45),
        fiber: _round1(info.fiber * 1.25),
        vitamins: info.vitamins,
        benefits: info.benefits,
        storageTips: info.storageTips,
        allergenNote: info.allergenNote,
      ),
      Ripeness.overripe => FruitInfo(
        label: info.label,
        nameId: info.nameId,
        calories: _round1(info.calories * 1.07),
        carbs: _round1(info.carbs * 1.07),
        sugar: _round1(info.sugar * 1.32),
        fiber: _round1(info.fiber * 0.78),
        vitamins: info.vitamins,
        benefits: info.benefits,
        storageTips: info.storageTips,
        allergenNote: info.allergenNote,
      ),
      Ripeness.ripe || Ripeness.rotten => info,
    };
  }

  static double _round1(double v) => (v * 10).round() / 10.0;
}
