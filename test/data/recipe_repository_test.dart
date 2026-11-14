import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';

void main() {
  const jsonSample = '''
  [
    {
      "id": 1,
      "title": "Smoothie Pisang",
      "fruit_label": "banana",
      "suitable_ripeness": ["ripe", "overripe"],
      "ingredients": ["1 pisang", "susu"],
      "steps": ["Blender"],
      "prep_time": "5 menit",
      "difficulty": "Mudah"
    },
    {
      "id": 2,
      "title": "Salad Apel",
      "fruit_label": "apple",
      "suitable_ripeness": ["ripe"],
      "ingredients": ["1 apel"],
      "steps": ["Potong"],
      "prep_time": "5 menit",
      "difficulty": "Mudah"
    }
  ]
  ''';

  test('RecipeRepository filters by fruit and ripeness', () async {
    final repo = AssetRecipeRepository(loadString: (_) async => jsonSample);

    final all = await repo.getAll();
    expect(all.length, 2);

    final bananaRipe = await repo.getRecipesForFruit(
      'banana',
      ripenessLabel: 'ripe',
    );
    expect(bananaRipe.length, 1);
    expect(bananaRipe.first.title, 'Smoothie Pisang');

    final appleOverripe = await repo.getRecipesForFruit(
      'apple',
      ripenessLabel: 'overripe',
    );
    expect(appleOverripe, isEmpty);
  });
}
