/// Static nutrition info for one fruit, values are per 100 g.
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
  });

  factory FruitInfo.fromJson(Map<String, Object?> json) {
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
    );
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
}
