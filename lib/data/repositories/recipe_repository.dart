import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/sources/app_database.dart';

/// Contract for accessing reviewed fruit recipe recommendations.
abstract class RecipeRepository {
  Future<List<Recipe>> getAll();
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  });
  Future<List<Recipe>> getReviewedByFruitAndBucket(
    String fruitId,
    RipenessBucket bucket,
  );
}

/// Asset-backed implementation of [RecipeRepository] (enforces `is_reviewed = true`).
class AssetRecipeRepository implements RecipeRepository {
  AssetRecipeRepository({Future<String> Function(String key)? loadString})
    : _loadString = loadString ?? rootBundle.loadString;

  static const String assetPath = 'assets/data/recipes.json';
  final Future<String> Function(String key) _loadString;
  Future<List<Recipe>>? _cache;

  @override
  Future<List<Recipe>> getAll() async {
    final all = await (_cache ??= _load());
    return all.where((r) => r.isReviewed).toList(growable: false);
  }

  @override
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  }) async {
    final all = await getAll();
    return all.where((r) {
      if (r.fruitLabel.toLowerCase() != fruitLabel.toLowerCase()) return false;
      if (ripenessLabel != null &&
          !r.suitableRipeness.contains(ripenessLabel.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Recipe>> getReviewedByFruitAndBucket(
    String fruitId,
    RipenessBucket bucket,
  ) async {
    final all = await getAll();
    final targetFruit = fruitId.trim().toLowerCase();
    return all
        .where(
          (r) =>
              r.isReviewed &&
              r.fruitLabel.toLowerCase() == targetFruit &&
              r.ripenessBucket == bucket,
        )
        .toList(growable: false);
  }

  Future<List<Recipe>> _load() async {
    final raw = await _loadString(assetPath);
    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map((e) => Recipe.fromJson(e! as Map<String, Object?>))
        .toList(growable: false);
  }
}

/// SQLite-backed implementation of [RecipeRepository] querying `recipes` table.
/// Enforces `is_reviewed = 1` on all read queries.
class SqfliteRecipeRepository implements RecipeRepository {
  SqfliteRecipeRepository({
    AppDatabase? appDatabase,
    AssetRecipeRepository? fallbackAssetRepo,
  }) : _appDatabase = appDatabase ?? AppDatabase.instance,
       _fallbackAssetRepo = fallbackAssetRepo ?? AssetRecipeRepository();

  final AppDatabase _appDatabase;
  final AssetRecipeRepository _fallbackAssetRepo;

  @override
  Future<List<Recipe>> getAll() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        AppDatabase.recipesTable,
        where: 'is_reviewed = 1',
        orderBy: 'id ASC',
      );
      return rows.map(Recipe.fromMap).toList(growable: false);
    } on MissingPluginException {
      return _fallbackAssetRepo.getAll();
    } on StateError {
      return _fallbackAssetRepo.getAll();
    }
  }

  @override
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  }) async {
    final all = await getAll();
    return all.where((r) {
      if (r.fruitLabel.toLowerCase() != fruitLabel.toLowerCase()) return false;
      if (ripenessLabel != null &&
          !r.suitableRipeness.contains(ripenessLabel.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Recipe>> getReviewedByFruitAndBucket(
    String fruitId,
    RipenessBucket bucket,
  ) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        AppDatabase.recipesTable,
        where:
            'LOWER(fruit_id) = ? AND ripeness_bucket = ? AND is_reviewed = 1',
        whereArgs: <Object>[fruitId.trim().toLowerCase(), bucket.dbValue],
        orderBy: 'id ASC',
      );
      return rows.map(Recipe.fromMap).toList(growable: false);
    } on MissingPluginException {
      return _fallbackAssetRepo.getReviewedByFruitAndBucket(fruitId, bucket);
    } on StateError {
      return _fallbackAssetRepo.getReviewedByFruitAndBucket(fruitId, bucket);
    }
  }
}
