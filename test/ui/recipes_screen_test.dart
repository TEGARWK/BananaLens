import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/ui/screens/recipe_detail_screen.dart';
import 'package:fruitlens/ui/screens/recipes_list_screen.dart';

class _FakeRecipeRepo implements RecipeRepository {
  @override
  Future<List<Recipe>> getAll() async => <Recipe>[
    const Recipe(
      id: 1,
      title: 'Es Semangka Manis',
      fruitLabel: 'watermelon',
      suitableRipeness: <String>['ripe'],
      ingredients: <String>['Semangka', 'Es batu'],
      steps: <String>['Potong semangka', 'Sajikan dingin'],
      prepTime: '5 menit',
      difficulty: 'Mudah',
    ),
  ];

  @override
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  }) async => getAll();

  @override
  Future<List<Recipe>> getReviewedByFruitAndBucket(
    String fruitId,
    RipenessBucket bucket,
  ) async => getAll();
}

void main() {
  testWidgets('renders recipes list screen and detail screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(_FakeRecipeRepo()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RecipesListScreen(fruitLabel: 'watermelon'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Es Semangka Manis'), findsOneWidget);
    expect(find.text('5 menit'), findsOneWidget);

    // Detail Screen test
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RecipeDetailScreen(
          recipe: Recipe(
            id: 1,
            title: 'Es Semangka Manis',
            fruitLabel: 'watermelon',
            suitableRipeness: <String>['ripe'],
            ingredients: <String>['Semangka segar', 'Es batu kristal'],
            steps: <String>['Potong dadu semangka', 'Sajikan dingin'],
            prepTime: '5 menit',
            difficulty: 'Mudah',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bahan-bahan yang Dibutuhkan'), findsOneWidget);
    expect(find.text('Semangka segar'), findsOneWidget);
    expect(find.text('Langkah Pembuatan'), findsOneWidget);
    expect(find.text('Potong dadu semangka'), findsOneWidget);
  });
}
