import 'dart:convert';

/// Ripeness bucket used to gate and categorize fruit recipes.
enum RipenessBucket {
  unripe('unripe', 'Mentah'),
  ripe('ripe', 'Matang Pas'),
  veryRipe('very_ripe', 'Matang Banget');

  const RipenessBucket(this.dbValue, this.labelId);

  final String dbValue;
  final String labelId;

  static RipenessBucket fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'unripe' => RipenessBucket.unripe,
      'very_ripe' || 'overripe' => RipenessBucket.veryRipe,
      _ => RipenessBucket.ripe,
    };
  }
}

/// Origin of a recipe entry.
enum RecipeSource { local, ai }

/// Culinary category for a recipe.
enum RecipeType {
  food('food', 'Makanan'),
  drink('drink', 'Minuman');

  const RecipeType(this.dbValue, this.labelId);

  final String dbValue;
  final String labelId;

  static RecipeType fromString(String value) {
    return value.trim().toLowerCase() == 'drink'
        ? RecipeType.drink
        : RecipeType.food;
  }
}

/// User-selected style/taste preference for AI recipe generation.
enum RecipePreference {
  any('any', 'Semua'),
  food('food', 'Makanan'),
  drink('drink', 'Minuman'),
  sweet('sweet', 'Manis'),
  savory('savory', 'Gurih'),
  quick('quick', 'Praktis');

  const RecipePreference(this.code, this.labelId);

  final String code;
  final String labelId;
}

/// Recipe entity stored in SQLite (`recipes` table) and seeded from JSON.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.fruitLabel,
    required this.suitableRipeness,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.difficulty,
    this.ripenessBucket = RipenessBucket.ripe,
    this.type = RecipeType.food,
    this.safetyNotes,
    this.isReviewed = true,
    this.source = RecipeSource.local,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, Object?> json) {
    final rawBucket = json['ripeness_bucket'] as String?;
    final rawSuitable = (json['suitable_ripeness'] as List<Object?>?)
        ?.map((e) => e.toString())
        .toList();

    final resolvedBucket = rawBucket != null
        ? RipenessBucket.fromString(rawBucket)
        : _inferBucketFromSuitable(rawSuitable);

    final suitableList =
        rawSuitable ??
        <String>[
          resolvedBucket == RipenessBucket.veryRipe
              ? 'overripe'
              : resolvedBucket.dbValue,
        ];

    final rawReviewed = json['is_reviewed'];
    final reviewed = rawReviewed is bool
        ? rawReviewed
        : (rawReviewed is num ? rawReviewed != 0 : true);

    return Recipe(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['name'] ?? json['title'])! as String,
      fruitLabel: (json['fruit_id'] ?? json['fruit_label'])! as String,
      suitableRipeness: suitableList,
      ingredients: _decodeStringList(json['ingredients']),
      steps: _decodeStringList(json['steps']),
      prepTime: json['prep_time'] as String? ?? '15 menit',
      difficulty: json['difficulty'] as String? ?? 'Mudah',
      ripenessBucket: resolvedBucket,
      type: RecipeType.fromString(json['type'] as String? ?? 'food'),
      safetyNotes: json['safety_notes'] as String?,
      isReviewed: reviewed,
      source: (json['source'] as String?)?.toLowerCase() == 'ai'
          ? RecipeSource.ai
          : RecipeSource.local,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory Recipe.fromMap(Map<String, Object?> map) => Recipe.fromJson(map);

  Map<String, Object?> toMap({bool includeId = true}) {
    final nowIso = DateTime.now().toIso8601String();
    return <String, Object?>{
      if (includeId && id > 0) 'id': id,
      'fruit_id': fruitLabel,
      'ripeness_bucket': ripenessBucket.dbValue,
      'name': title,
      'type': type.dbValue,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(steps),
      'safety_notes': safetyNotes,
      'is_reviewed': isReviewed ? 1 : 0,
      'prep_time': prepTime,
      'difficulty': difficulty,
      'created_at': createdAt?.toIso8601String() ?? nowIso,
      'updated_at': updatedAt?.toIso8601String() ?? nowIso,
    };
  }

  final int id;
  final String title;
  final String fruitLabel;
  final List<String> suitableRipeness;
  final List<String> ingredients;
  final List<String> steps;
  final String prepTime;
  final String difficulty;
  final RipenessBucket ripenessBucket;
  final RecipeType type;
  final String? safetyNotes;
  final bool isReviewed;
  final RecipeSource source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get name => title;
  String get fruitId => fruitLabel;

  static RipenessBucket _inferBucketFromSuitable(List<String>? suitable) {
    if (suitable == null || suitable.isEmpty) return RipenessBucket.ripe;
    if (suitable.contains('unripe')) return RipenessBucket.unripe;
    if (suitable.contains('overripe') && !suitable.contains('ripe')) {
      return RipenessBucket.veryRipe;
    }
    return RipenessBucket.ripe;
  }

  static List<String> _decodeStringList(Object? raw) {
    if (raw is List<Object?>) {
      return raw.map((e) => e.toString()).toList(growable: false);
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<Object?>;
      return decoded.map((e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
