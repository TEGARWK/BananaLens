/// Static nutrition & ripeness-edibility info for one fruit, values are per 100 g.
class FruitInfo {
  const FruitInfo({
    required this.label,
    required this.nameId,
    required this.calories,
    required this.carbs,
    required this.sugar,
    required this.fiber,
    required this.vitamins,
    required this.benefits,
    required this.storageTips,
    required this.allergenNote,
    this.edibleWhenUnripe = false,
  });

  factory FruitInfo.fromJson(Map<String, Object?> json) {
    final rawEdible = json['edible_when_unripe'];
    final edible = rawEdible is bool
        ? rawEdible
        : (rawEdible is num ? rawEdible != 0 : false);

    return FruitInfo(
      label: json['label']! as String,
      nameId: json['name_id']! as String,
      calories: (json['calories']! as num).toDouble(),
      carbs: (json['carbs']! as num).toDouble(),
      sugar: (json['sugar']! as num).toDouble(),
      fiber: (json['fiber']! as num).toDouble(),
      vitamins: json['vitamins']! as String,
      benefits: json['benefits']! as String,
      storageTips: json['storage_tips']! as String,
      allergenNote: json['allergen_note']! as String,
      edibleWhenUnripe: edible,
    );
  }

  factory FruitInfo.fromMap(Map<String, Object?> map) =>
      FruitInfo.fromJson(map);

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'label': label,
      'name_id': nameId,
      'calories': calories,
      'carbs': carbs,
      'sugar': sugar,
      'fiber': fiber,
      'vitamins': vitamins,
      'benefits': benefits,
      'storage_tips': storageTips,
      'allergen_note': allergenNote,
      'edible_when_unripe': edibleWhenUnripe ? 1 : 0,
    };
  }

  /// Model label, e.g. `apple`. Must match labels_fruit.txt.
  final String label;
  final String nameId;
  final double calories;
  final double carbs;
  final double sugar;
  final double fiber;
  final String vitamins;
  final String benefits;
  final String storageTips;
  final String allergenNote;
  final bool edibleWhenUnripe;
}
