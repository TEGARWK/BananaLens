import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/gemini_recipe_service.dart';
import 'package:fruitlens/services/recipe_gating_service.dart';
import 'package:fruitlens/services/spk_decision_service.dart';

/// Arguments passed to [ScanRecipesScreen] and [scanRecipesProvider].
class ScanRecipesArgs {
  const ScanRecipesArgs({
    required this.outcome,
    required this.bucket,
    required this.fruitName,
    this.preference = RecipePreference.any,
  });

  final ScanSuccess outcome;
  final RipenessBucket bucket;
  final String fruitName;
  final RecipePreference preference;

  ScanRecipesArgs copyWith({RecipePreference? preference}) {
    return ScanRecipesArgs(
      outcome: outcome,
      bucket: bucket,
      fruitName: fruitName,
      preference: preference ?? this.preference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanRecipesArgs &&
        other.outcome == outcome &&
        other.bucket == bucket &&
        other.fruitName == fruitName &&
        other.preference == preference;
  }

  @override
  int get hashCode => Object.hash(outcome, bucket, fruitName, preference);
}

/// Live Gemini recipe generator provider (separate from Chat AI Assistant).
/// Returns `null` when GEMINI_API_KEY is absent (e.g. offline/test harness),
/// causing [RecipeGatingService] to fall back cleanly to local backup recipes.
final liveRecipeGeneratorProvider = Provider<LiveRecipeGenerator?>((ref) {
  final geminiKey = dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null;
  final modelName = dotenv.isInitialized ? dotenv.env['GEMINI_MODEL'] : null;
  if (geminiKey != null && geminiKey.trim().isNotEmpty) {
    return GeminiRecipeService(
      apiKey: geminiKey.trim(),
      modelName: modelName?.trim().isNotEmpty == true
          ? modelName!.trim()
          : 'gemini-3.5-flash-lite',
    );
  }
  return null;
});

final recipeGatingServiceProvider = Provider<RecipeGatingService>((ref) {
  return RecipeGatingService(
    fruitInfoRepository: ref.watch(fruitInfoRepositoryProvider),
    recipeRepository: ref.watch(recipeRepositoryProvider),
    liveRecipeGenerator: ref.watch(liveRecipeGeneratorProvider),
  );
});

/// Loads and caches the offline PSO-Random Forest SPK model (`spk_pso_rf_model.json`).
/// Returns `null` if the asset is unavailable (e.g. minimal widget tests).
final spkDecisionProvider = FutureProvider<SpkDecisionService?>((ref) async {
  try {
    return await SpkDecisionService.loadFromAssets();
  } catch (_) {
    return null;
  }
});

/// Evaluates post-scan recipe gating locally without calling Gemini AI.
final recipeGateProvider = FutureProvider.autoDispose
    .family<RecipeGateResult, ScanSuccess>((ref, outcome) {
      return ref.watch(recipeGatingServiceProvider).evaluateGateOnly(outcome);
    });

/// Fetches live Gemini AI recipes (with local JSON/SQLite backup on offline/limit)
/// ONLY when the user opens the Scan Recipes page or picks a style preference.
final scanRecipesProvider = FutureProvider.autoDispose
    .family<ScanRecipesResult, ScanRecipesArgs>((ref, args) {
      return ref
          .watch(recipeGatingServiceProvider)
          .fetchRecipesForScan(
            outcome: args.outcome,
            bucket: args.bucket,
            preference: args.preference,
          );
    });
