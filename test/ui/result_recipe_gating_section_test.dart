import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/providers/recipe_gating_provider.dart';
import 'package:fruitlens/services/recipe_gating_service.dart';
import 'package:fruitlens/ui/screens/scan_recipes_screen.dart';
import 'package:fruitlens/ui/widgets/result_recipe_gating_section.dart';

void main() {
  const sampleOutcome = ScanSuccess(
    fruitLabel: 'banana',
    ripenessLabel: 'ripe',
    fruitConfidence: 0.9,
    ripenessConfidence: 0.9,
  );

  testWidgets('renders static discard warning when rotten', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeGateProvider(sampleOutcome).overrideWith(
            (ref) async => const RottenDiscardResult(fruitName: 'Pisang'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ResultRecipeGatingSection(outcome: sampleOutcome),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buang saja, jangan dikonsumsi'), findsOneWidget);
    expect(find.text('Rekomendasi Resep'), findsNothing);
  });

  testWidgets('renders wait-only card when unripe and not edible', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeGateProvider(sampleOutcome).overrideWith(
            (ref) async => const UnripeWaitOnlyResult(
              fruitName: 'Alpukat',
              estimatedDays: '3–5 hari',
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ResultRecipeGatingSection(outcome: sampleOutcome),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tunggu dulu sampai matang'), findsOneWidget);
    expect(find.textContaining('3–5 hari'), findsOneWidget);
    expect(find.text('Rekomendasi Resep'), findsNothing);
  });

  testWidgets(
    'renders dual options for edible unripe fruit and switches tabs',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeGateProvider(sampleOutcome).overrideWith(
              (ref) async => const UnripeDualOptionResult(
                fruitName: 'Pisang',
                estimatedDays: '4–5 hari',
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: ResultRecipeGatingSection(outcome: sampleOutcome),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tunggu matang'), findsOneWidget);
      expect(find.text('Masak sekarang'), findsOneWidget);
      expect(find.textContaining('4–5 hari'), findsOneWidget);

      await tester.tap(find.text('Masak sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Rekomendasi Resep'), findsOneWidget);
    },
  );

  testWidgets('renders Rekomendasi Resep button when ripe', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeGateProvider(sampleOutcome).overrideWith(
            (ref) async => const RipeBucketReadyResult(
              fruitName: 'Pisang',
              bucket: RipenessBucket.ripe,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ResultRecipeGatingSection(outcome: sampleOutcome),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rekomendasi Resep'), findsOneWidget);
    expect(find.text('Matang Pas'), findsOneWidget);
  });

  testWidgets('ScanRecipesScreen renders AI recipes and backup recipes below', (
    tester,
  ) async {
    const args = ScanRecipesArgs(
      outcome: sampleOutcome,
      bucket: RipenessBucket.veryRipe,
      fruitName: 'Pisang',
    );
    const aiRecipe = Recipe(
      id: 10000,
      title: 'Banana Bread Gemini',
      fruitLabel: 'banana',
      suitableRipeness: <String>['overripe'],
      ingredients: <String>['Pisang'],
      steps: <String>['Panggang'],
      prepTime: '30 menit',
      difficulty: 'Mudah',
      ripenessBucket: RipenessBucket.veryRipe,
      type: RecipeType.food,
    );
    const curatedRecipe = Recipe(
      id: 2,
      title: 'Pancake Pisang Terkurasi',
      fruitLabel: 'banana',
      suitableRipeness: <String>['overripe'],
      ingredients: <String>['Pisang'],
      steps: <String>['Masak di teflon'],
      prepTime: '15 menit',
      difficulty: 'Mudah',
      ripenessBucket: RipenessBucket.veryRipe,
      type: RecipeType.food,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanRecipesProvider(args).overrideWith(
            (ref) async => const ScanRecipesResult(
              aiRecipes: <Recipe>[aiRecipe],
              backupRecipes: <Recipe>[curatedRecipe],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScanRecipesScreen(args: args),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ide Resep Spesial AI'), findsOneWidget);
    expect(find.text('Banana Bread Gemini'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Gurih'), findsOneWidget);
    expect(find.text('Minuman'), findsOneWidget);
    expect(find.text('Resep Pilihan Lainnya'), findsOneWidget);
    expect(find.text('Pancake Pisang Terkurasi'), findsOneWidget);
    expect(find.textContaining('Resep dibuat khusus oleh AI'), findsOneWidget);
  });

  testWidgets('ScanRecipesScreen renders backup notice when offline/limit', (
    tester,
  ) async {
    const args = ScanRecipesArgs(
      outcome: sampleOutcome,
      bucket: RipenessBucket.veryRipe,
      fruitName: 'Pisang',
    );
    const backupRecipe = Recipe(
      id: 1,
      title: 'Smoothie Pisang Backup',
      fruitLabel: 'banana',
      suitableRipeness: <String>['overripe'],
      ingredients: <String>['Pisang'],
      steps: <String>['Blender'],
      prepTime: '10 menit',
      difficulty: 'Mudah',
      ripenessBucket: RipenessBucket.veryRipe,
      type: RecipeType.drink,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanRecipesProvider(args).overrideWith(
            (ref) async => const ScanRecipesResult(
              backupRecipes: <Recipe>[backupRecipe],
              fallbackReason:
                  'Kamu sedang offline. Menampilkan resep pilihan yang bisa dibuka tanpa internet.',
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScanRecipesScreen(args: args),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resep Pilihan Offline'), findsOneWidget);
    expect(find.text('Smoothie Pisang Backup'), findsOneWidget);
    expect(find.textContaining('sedang offline'), findsOneWidget);
  });
}
