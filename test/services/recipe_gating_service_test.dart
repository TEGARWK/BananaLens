import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';
import 'package:fruitlens/services/gemini_recipe_service.dart';
import 'package:fruitlens/services/recipe_gating_service.dart';

class _StubFruitRepo implements FruitInfoRepository {
  static const Map<String, FruitInfo> _items = <String, FruitInfo>{
    'banana': FruitInfo(
      label: 'banana',
      nameId: 'Pisang',
      calories: 89,
      carbs: 22.8,
      sugar: 12.2,
      fiber: 2.6,
      vitamins: 'B6, C',
      benefits: 'Energi cepat',
      storageTips: 'Suhu ruang',
      allergenNote: 'Lateks',
      edibleWhenUnripe: true,
    ),
    'avocado': FruitInfo(
      label: 'avocado',
      nameId: 'Alpukat',
      calories: 160,
      carbs: 8.5,
      sugar: 0.7,
      fiber: 6.7,
      vitamins: 'K, E',
      benefits: 'Lemak sehat',
      storageTips: 'Suhu ruang',
      allergenNote: 'Lateks',
      edibleWhenUnripe: false,
    ),
  };

  @override
  Future<List<FruitInfo>> getAll() async => _items.values.toList();

  @override
  Future<FruitInfo?> getByLabel(String label) async =>
      _items[label.toLowerCase()];
}

class _StubRecipeRepo implements RecipeRepository {
  static const List<Recipe> _recipes = <Recipe>[
    Recipe(
      id: 1,
      title: 'Keripik Pisang Mentah',
      fruitLabel: 'banana',
      suitableRipeness: <String>['unripe'],
      ingredients: <String>['Pisang mentah', 'Garam'],
      steps: <String>['Rendam garam lalu goreng hingga matang.'],
      prepTime: '30 menit',
      difficulty: 'Sedang',
      ripenessBucket: RipenessBucket.unripe,
      type: RecipeType.food,
      safetyNotes: 'Wajib dimasak matang sempurna.',
      isReviewed: true,
    ),
    Recipe(
      id: 2,
      title: 'Draft Resep Belum Direview',
      fruitLabel: 'banana',
      suitableRipeness: <String>['unripe'],
      ingredients: <String>['Pisang mentah'],
      steps: <String>['Draft'],
      prepTime: '10 menit',
      difficulty: 'Mudah',
      ripenessBucket: RipenessBucket.unripe,
      type: RecipeType.food,
      safetyNotes: 'Draft',
      isReviewed: false,
    ),
    Recipe(
      id: 3,
      title: 'Oatmeal Pisang Segar',
      fruitLabel: 'banana',
      suitableRipeness: <String>['ripe'],
      ingredients: <String>['Pisang', 'Oatmeal'],
      steps: <String>['Seduh oatmeal, tambahkan irisan pisang.'],
      prepTime: '10 menit',
      difficulty: 'Sangat Mudah',
      ripenessBucket: RipenessBucket.ripe,
      type: RecipeType.food,
      isReviewed: true,
    ),
    Recipe(
      id: 4,
      title: 'Smoothie Pisang Madu',
      fruitLabel: 'banana',
      suitableRipeness: <String>['overripe'],
      ingredients: <String>['Pisang sangat matang', 'Susu'],
      steps: <String>['Blender hingga halus.'],
      prepTime: '10 menit',
      difficulty: 'Sangat Mudah',
      ripenessBucket: RipenessBucket.veryRipe,
      type: RecipeType.drink,
      isReviewed: true,
    ),
  ];

  @override
  Future<List<Recipe>> getAll() async =>
      _recipes.where((r) => r.isReviewed).toList();

  @override
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  }) async => getAll();

  @override
  Future<List<Recipe>> getReviewedByFruitAndBucket(
    String fruitId,
    RipenessBucket bucket,
  ) async {
    return _recipes
        .where(
          (r) =>
              r.isReviewed &&
              r.fruitLabel == fruitId &&
              r.ripenessBucket == bucket,
        )
        .toList();
  }
}

class _FakeLiveGenerator implements LiveRecipeGenerator {
  _FakeLiveGenerator({
    this.recipes = const <Recipe>[],
    this.shouldThrow = false,
  });

  final List<Recipe> recipes;
  final bool shouldThrow;
  int callCount = 0;
  RecipePreference? lastPreference;

  @override
  Future<List<Recipe>> generate({
    required String fruitId,
    required String fruitNameId,
    required RipenessBucket bucket,
    required double confidence,
    RecipePreference preference = RecipePreference.any,
  }) async {
    callCount++;
    lastPreference = preference;
    if (shouldThrow) throw Exception('Offline or quota exceeded');
    return recipes;
  }
}

void main() {
  test(
    'evaluateGateOnly never calls LiveRecipeGenerator (0 quota on scan)',
    () async {
      final liveGen = _FakeLiveGenerator();
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
        liveRecipeGenerator: liveGen,
      );

      const ripeOutcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.95,
        ripenessConfidence: 0.96,
        classProbabilities: <String, double>{
          'unripe': 0.01,
          'ripe': 0.96,
          'rotten': 0.03,
        },
      );

      final gate = await service.evaluateGateOnly(ripeOutcome);
      expect(gate, isA<RipeBucketReadyResult>());
      expect((gate as RipeBucketReadyResult).bucket, RipenessBucket.ripe);
      expect(liveGen.callCount, 0);
    },
  );

  test('rotten returns RottenDiscardResult', () async {
    final service = RecipeGatingService(
      fruitInfoRepository: _StubFruitRepo(),
      recipeRepository: _StubRecipeRepo(),
    );

    const outcome = ScanSuccess(
      fruitLabel: 'banana',
      ripenessLabel: 'rotten',
      fruitConfidence: 0.95,
      ripenessConfidence: 0.99,
    );

    final result = await service.evaluateGateOnly(outcome);
    expect(result, isA<RottenDiscardResult>());
    expect((result as RottenDiscardResult).fruitName, 'Pisang');
  });

  test(
    'unripe + edibleWhenUnripe=false returns UnripeWaitOnlyResult',
    () async {
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
      );

      const outcome = ScanSuccess(
        fruitLabel: 'avocado',
        ripenessLabel: 'unripe',
        fruitConfidence: 0.90,
        ripenessConfidence: 0.85,
      );

      final result = await service.evaluateGateOnly(outcome);
      expect(result, isA<UnripeWaitOnlyResult>());
      final waitOnly = result as UnripeWaitOnlyResult;
      expect(waitOnly.fruitName, 'Alpukat');
      expect(waitOnly.estimatedDays, '3–5 hari');
    },
  );

  test(
    'unripe + edibleWhenUnripe=true returns UnripeDualOptionResult',
    () async {
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
      );

      const outcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'unripe',
        fruitConfidence: 0.92,
        ripenessConfidence: 0.85,
      );

      final result = await service.evaluateGateOnly(outcome);
      expect(result, isA<UnripeDualOptionResult>());
      final dual = result as UnripeDualOptionResult;
      expect(dual.estimatedDays, '4–5 hari');
      expect(dual.bucket, RipenessBucket.unripe);
    },
  );

  test(
    'ripe with elevated rotten prob (>= 15%) resolves to very_ripe bucket',
    () async {
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
      );

      const outcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.90,
        ripenessConfidence: 0.82,
        classProbabilities: <String, double>{
          'unripe': 0.01,
          'ripe': 0.82,
          'rotten': 0.17,
        },
      );

      final result = await service.evaluateGateOnly(outcome);
      expect(result, isA<RipeBucketReadyResult>());
      expect((result as RipeBucketReadyResult).bucket, RipenessBucket.veryRipe);
    },
  );

  test(
    '4-class ripe (with native overripe key) stays in ripe bucket even if confidence < 75%',
    () async {
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
      );

      const outcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.90,
        ripenessConfidence: 0.642,
        classProbabilities: <String, double>{
          'unripe': 0.003,
          'ripe': 0.642,
          'overripe': 0.213,
          'rotten': 0.141,
        },
      );

      final result = await service.evaluateGateOnly(outcome);
      expect(result, isA<RipeBucketReadyResult>());
      expect((result as RipeBucketReadyResult).bucket, RipenessBucket.ripe);
    },
  );

  test('4-class overripe resolves directly to very_ripe bucket', () async {
    final service = RecipeGatingService(
      fruitInfoRepository: _StubFruitRepo(),
      recipeRepository: _StubRecipeRepo(),
    );

    const outcome = ScanSuccess(
      fruitLabel: 'banana',
      ripenessLabel: 'overripe',
      fruitConfidence: 0.92,
      ripenessConfidence: 0.78,
      classProbabilities: <String, double>{
        'unripe': 0.01,
        'ripe': 0.15,
        'overripe': 0.78,
        'rotten': 0.06,
      },
    );

    final result = await service.evaluateGateOnly(outcome);
    expect(result, isA<RipeBucketReadyResult>());
    expect((result as RipeBucketReadyResult).bucket, RipenessBucket.veryRipe);
  });

  test('unknown fruit returns UnknownFruitResult', () async {
    final service = RecipeGatingService(
      fruitInfoRepository: _StubFruitRepo(),
      recipeRepository: _StubRecipeRepo(),
    );

    const outcome = ScanSuccess(
      fruitLabel: 'durian',
      ripenessLabel: 'ripe',
      fruitConfidence: 0.80,
      ripenessConfidence: 0.80,
    );

    final result = await service.evaluateGateOnly(outcome);
    expect(result, isA<UnknownFruitResult>());
  });

  test(
    'fetchRecipesForScan calls LiveRecipeGenerator and returns isFromLiveAi=true',
    () async {
      final liveGen = _FakeLiveGenerator(
        recipes: const <Recipe>[
          Recipe(
            id: 10000,
            title: 'Banana Bread AI Live',
            fruitLabel: 'banana',
            suitableRipeness: <String>['overripe'],
            ingredients: <String>['Pisang matang banget'],
            steps: <String>['Panggang 30 menit'],
            prepTime: '35 menit',
            difficulty: 'Mudah',
            ripenessBucket: RipenessBucket.veryRipe,
            type: RecipeType.food,
          ),
        ],
      );
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
        liveRecipeGenerator: liveGen,
      );

      const outcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.90,
        ripenessConfidence: 0.80,
      );

      final result = await service.fetchRecipesForScan(
        outcome: outcome,
        bucket: RipenessBucket.veryRipe,
        preference: RecipePreference.savory,
      );
      expect(liveGen.callCount, 1);
      expect(liveGen.lastPreference, RecipePreference.savory);
      expect(result.isFromLiveAi, isTrue);
      expect(result.aiRecipes.single.name, 'Banana Bread AI Live');
      expect(result.backupRecipes.single.name, 'Smoothie Pisang Madu');
      expect(result.recipes.first.name, 'Banana Bread AI Live');
      expect(result.recipes.last.name, 'Smoothie Pisang Madu');
    },
  );

  test(
    'fetchRecipesForScan falls back to local reviewed backup when offline/limit',
    () async {
      final liveGen = _FakeLiveGenerator(shouldThrow: true);
      final service = RecipeGatingService(
        fruitInfoRepository: _StubFruitRepo(),
        recipeRepository: _StubRecipeRepo(),
        liveRecipeGenerator: liveGen,
      );

      const outcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        fruitConfidence: 0.95,
        ripenessConfidence: 0.95,
      );

      final result = await service.fetchRecipesForScan(
        outcome: outcome,
        bucket: RipenessBucket.ripe,
      );
      expect(liveGen.callCount, 1);
      expect(result.isFromLiveAi, isFalse);
      expect(result.aiRecipes, isEmpty);
      expect(result.backupRecipes.single.name, 'Oatmeal Pisang Segar');
    },
  );

  test('GeminiRecipeService.parseAndValidateResponse parses valid JSON', () {
    const jsonText = '''
    {
      "fruit": "banana",
      "ripeness_bucket": "very_ripe",
      "recipes": [
        {
          "name": "Jus Pisang Kurma",
          "type": "drink",
          "ingredients": ["2 pisang matang banget", "3 kurma"],
          "steps": ["Blender semua bahan."],
          "safety_notes": null
        }
      ]
    }
    ''';

    final recipes = GeminiRecipeService.parseAndValidateResponse(
      jsonText,
      fruitId: 'banana',
      bucket: RipenessBucket.veryRipe,
    );
    expect(recipes.length, 1);
    expect(recipes.first.name, 'Jus Pisang Kurma');
    expect(recipes.first.type, RecipeType.drink);
    expect(recipes.first.ripenessBucket, RipenessBucket.veryRipe);
  });
}
