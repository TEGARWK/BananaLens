import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fruitlens/core/constants/ripeness_recipe_config.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';
import 'package:fruitlens/services/gemini_recipe_service.dart';

/// Deterministic gating output for the post-scan Result screen.
/// Does NOT trigger any LLM call on its own, preserving API quota until the user
/// explicitly taps the "Rekomendasi Resep" button.
sealed class RecipeGateResult {
  const RecipeGateResult();
}

/// Fruit is rotten: static food-safety warning, no recipe button.
final class RottenDiscardResult extends RecipeGateResult {
  const RottenDiscardResult({required this.fruitName});
  final String fruitName;
}

/// Fruit is unripe and `edible_when_unripe = false`: wait message + rough day estimate.
final class UnripeWaitOnlyResult extends RecipeGateResult {
  const UnripeWaitOnlyResult({
    required this.fruitName,
    required this.estimatedDays,
  });
  final String fruitName;
  final String estimatedDays;
}

/// Fruit is unripe and `edible_when_unripe = true`: user can wait or tap to view unripe recipes.
final class UnripeDualOptionResult extends RecipeGateResult {
  const UnripeDualOptionResult({
    required this.fruitName,
    required this.estimatedDays,
    this.bucket = RipenessBucket.unripe,
  });
  final String fruitName;
  final String estimatedDays;
  final RipenessBucket bucket;
}

/// Fruit is ripe (`ripe` or `very_ripe` bucket): ready to open recipe recommendations.
final class RipeBucketReadyResult extends RecipeGateResult {
  const RipeBucketReadyResult({required this.fruitName, required this.bucket});
  final String fruitName;
  final RipenessBucket bucket;
}

/// Fruit is not in the known database: hide recipe section cleanly.
final class UnknownFruitResult extends RecipeGateResult {
  const UnknownFruitResult();
}

/// Output of loading recipes for a scan result (live Gemini AI + local JSON/SQLite backup).
class ScanRecipesResult {
  const ScanRecipesResult({
    this.aiRecipes = const <Recipe>[],
    this.backupRecipes = const <Recipe>[],
    this.fallbackReason,
  });

  final List<Recipe> aiRecipes;
  final List<Recipe> backupRecipes;
  final String? fallbackReason;

  bool get isFromLiveAi => aiRecipes.isNotEmpty;
  List<Recipe> get recipes => <Recipe>[...aiRecipes, ...backupRecipes];
}

/// Deterministic rule-based gating service for post-scan recipes.
/// - `evaluateGateOnly`: runs locally with 0 LLM calls.
/// - `fetchRecipesForScan`: called only when user taps "Rekomendasi Resep", calling
///   Gemini live with automatic fallback to local JSON/SQLite backup when offline or quota-limited.
class RecipeGatingService {
  RecipeGatingService({
    required FruitInfoRepository fruitInfoRepository,
    required RecipeRepository recipeRepository,
    LiveRecipeGenerator? liveRecipeGenerator,
  }) : _fruitRepo = fruitInfoRepository,
       _recipeRepo = recipeRepository,
       _liveGenerator = liveRecipeGenerator;

  final FruitInfoRepository _fruitRepo;
  final RecipeRepository _recipeRepo;
  final LiveRecipeGenerator? _liveGenerator;

  /// Evaluates food-safety & ripeness gating locally without calling any LLM.
  Future<RecipeGateResult> evaluateGateOnly(ScanSuccess outcome) async {
    final fruit = await _fruitRepo.getByLabel(outcome.fruitLabel);
    if (fruit == null) {
      return const UnknownFruitResult();
    }

    final ripeness = outcome.ripenessLabel.trim().toLowerCase();
    if (ripeness == 'rotten') {
      return RottenDiscardResult(fruitName: fruit.nameId);
    }

    if (ripeness == 'unripe') {
      final estimatedDays = RipenessRecipeConfig.estimateWaitDays(
        fruit.label,
        outcome.ripenessConfidence,
      );
      if (!fruit.edibleWhenUnripe) {
        return UnripeWaitOnlyResult(
          fruitName: fruit.nameId,
          estimatedDays: estimatedDays,
        );
      }
      return UnripeDualOptionResult(
        fruitName: fruit.nameId,
        estimatedDays: estimatedDays,
      );
    }

    final bucket = RipenessRecipeConfig.resolveRipeBucket(outcome);
    return RipeBucketReadyResult(fruitName: fruit.nameId, bucket: bucket);
  }

  /// Fetches recipes for an eligible scan bucket using live Gemini AI first,
  /// falling back to reviewed local SQLite/JSON backup when offline or quota-limited.
  Future<ScanRecipesResult> fetchRecipesForScan({
    required ScanSuccess outcome,
    required RipenessBucket bucket,
    RecipePreference preference = RecipePreference.any,
  }) async {
    final fruit = await _fruitRepo.getByLabel(outcome.fruitLabel);
    final fruitId = fruit?.label ?? outcome.fruitLabel;
    final fruitNameId = fruit?.nameId ?? outcome.fruitLabel;

    final allBackup = await _recipeRepo.getReviewedByFruitAndBucket(
      fruitId,
      bucket,
    );
    final backup = _filterBackupByPreference(allBackup, preference);

    String? fallbackReason;
    List<Recipe> aiRecipes = const <Recipe>[];
    final generator = _liveGenerator;
    if (generator == null) {
      fallbackReason = 'Menampilkan resep pilihan yang sudah dikurasi.';
    } else {
      try {
        final generated = await generator
            .generate(
              fruitId: fruitId,
              fruitNameId: fruitNameId,
              bucket: bucket,
              confidence: outcome.ripenessConfidence,
              preference: preference,
            )
            .timeout(const Duration(seconds: 15));
        if (generated.isNotEmpty) {
          aiRecipes = generated;
        } else {
          fallbackReason =
              'Resep pintar belum tersedia saat ini. Menampilkan resep pilihan yang sudah tersimpan.';
        }
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        debugPrint('LiveRecipeGenerator DioException ($code): ${e.message}');
        if (code == 429) {
          fallbackReason =
              'Layanan resep pintar sedang ramai. Menampilkan resep pilihan yang sudah tersimpan.';
        } else if (code == 503) {
          fallbackReason =
              'Layanan resep pintar sedang sibuk. Menampilkan resep pilihan yang sudah tersimpan.';
        } else if (code != null) {
          fallbackReason =
              'Layanan resep pintar sedang gangguan sementara. Menampilkan resep pilihan.';
        } else {
          fallbackReason =
              'Kamu sedang offline. Menampilkan resep pilihan yang bisa dibuka tanpa internet.';
        }
      } catch (e) {
        debugPrint('LiveRecipeGenerator fallback: $e');
        fallbackReason =
            'Asisten resep pintar sedang tidak bisa dihubungi. Menampilkan resep pilihan.';
      }
    }

    return ScanRecipesResult(
      aiRecipes: aiRecipes,
      backupRecipes: backup,
      fallbackReason: aiRecipes.isEmpty ? fallbackReason : null,
    );
  }

  List<Recipe> _filterBackupByPreference(
    List<Recipe> allBackup,
    RecipePreference preference,
  ) {
    if (allBackup.isEmpty || preference == RecipePreference.any) {
      return allBackup;
    }
    final filtered = switch (preference) {
      RecipePreference.food =>
        allBackup.where((r) => r.type == RecipeType.food).toList(),
      RecipePreference.drink =>
        allBackup.where((r) => r.type == RecipeType.drink).toList(),
      _ => allBackup,
    };
    return filtered.isNotEmpty ? filtered : allBackup;
  }
}
