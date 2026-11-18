/// Utility for Indonesian fruit names and relative date formatting.
abstract final class FruitNameHelper {
  /// Converts an English fruit label (e.g. 'banana', 'apple') to Indonesian display name.
  static String toIndonesian(String fruitLabel) {
    return switch (fruitLabel.toLowerCase()) {
      'banana' => 'Pisang',
      'apple' => 'Apel',
      'avocado' => 'Alpukat',
      'orange' => 'Jeruk',
      'mango' => 'Mangga',
      'watermelon' => 'Semangka',
      'strawberry' => 'Stroberi',
      'pineapple' => 'Nanas',
      'papaya' => 'Pepaya',
      'grape' => 'Anggur',
      'tomato' => 'Tomat',
      _ =>
        fruitLabel.isNotEmpty
            ? '${fruitLabel[0].toUpperCase()}${fruitLabel.substring(1)}'
            : fruitLabel,
    };
  }

  /// Formats a [DateTime] into a friendly relative Indonesian string.
  static String formatRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
