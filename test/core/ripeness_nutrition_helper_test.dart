import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/utils/ripeness_nutrition_helper.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/ripeness.dart';

void main() {
  const baseBanana = FruitInfo(
    label: 'banana',
    nameId: 'Pisang',
    calories: 89,
    carbs: 22.8,
    sugar: 12.2,
    fiber: 2.6,
    vitamins: 'Vitamin B6, C, Kalium',
    benefits: 'Sumber energi cepat',
    storageTips: 'Simpan di suhu ruang',
    allergenNote: 'Aman',
  );

  group('RipenessNutritionHelper', () {
    test('increases sugar and lowers fiber as banana ripens', () {
      final unripe = RipenessNutritionHelper.adjust(
        baseBanana,
        Ripeness.unripe,
      )!;
      final ripe = RipenessNutritionHelper.adjust(baseBanana, Ripeness.ripe)!;
      final overripe = RipenessNutritionHelper.adjust(
        baseBanana,
        Ripeness.overripe,
      )!;

      expect(unripe.sugar, lessThan(ripe.sugar));
      expect(ripe.sugar, lessThan(overripe.sugar));

      expect(unripe.fiber, greaterThan(ripe.fiber));
      expect(ripe.fiber, greaterThan(overripe.fiber));

      expect(unripe.calories, lessThan(ripe.calories));
      expect(ripe.calories, lessThan(overripe.calories));
    });

    test('returns null nutrition for rotten fruit (unsafe to consume)', () {
      final rotten = RipenessNutritionHelper.adjust(
        baseBanana,
        Ripeness.rotten,
      );
      expect(rotten, isNull);
    });
  });
}
