import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fruitlens/data/models/recipe.dart';

/// Contract for accessing fruit recipe recommendations.
abstract class RecipeRepository {
  Future<List<Recipe>> getAll();
  Future<List<Recipe>> getRecipesForFruit(
    String fruitLabel, {
    String? ripenessLabel,
  });
}

/// Asset-backed implementation of [RecipeRepository].
class AssetRecipeRepository implements RecipeRepository {
  AssetRecipeRepository({Future<String> Function(String key)? loadString})
    : _loadString = loadString ?? rootBundle.loadString;

  static const String assetPath = 'assets/data/recipes.json';
  final Future<String> Function(String key) _loadString;
  Future<List<Recipe>>? _cache;

  @override
  Future<List<Recipe>> getAll() => _cache ??= _load();

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

  Future<List<Recipe>> _load() async {
    final raw = await _loadString(assetPath);
    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map((e) => Recipe.fromJson(e! as Map<String, Object?>))
        .toList(growable: false);
  }
}
