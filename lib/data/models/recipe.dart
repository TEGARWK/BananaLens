/// Static recipe data for fruit processing.
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
  });

  factory Recipe.fromJson(Map<String, Object?> json) {
    return Recipe(
      id: json['id']! as int,
      title: json['title']! as String,
      fruitLabel: json['fruit_label']! as String,
      suitableRipeness: (json['suitable_ripeness']! as List<Object?>)
          .map((e) => e.toString())
          .toList(),
      ingredients: (json['ingredients']! as List<Object?>)
          .map((e) => e.toString())
          .toList(),
      steps: (json['steps']! as List<Object?>)
          .map((e) => e.toString())
          .toList(),
      prepTime: json['prep_time'] as String? ?? '15 menit',
      difficulty: json['difficulty'] as String? ?? 'Mudah',
    );
  }

  final int id;
  final String title;
  final String fruitLabel;
  final List<String> suitableRipeness;
  final List<String> ingredients;
  final List<String> steps;
  final String prepTime;
  final String difficulty;
}
