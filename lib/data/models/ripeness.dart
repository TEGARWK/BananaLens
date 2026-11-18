/// Ripeness classes produced by the ripeness model (labels_ripeness.txt).
enum Ripeness {
  unripe,
  ripe,
  overripe,
  rotten;

  /// Indonesian display label for this ripeness class.
  String get labelId => switch (this) {
    Ripeness.unripe => 'Mentah',
    Ripeness.ripe => 'Matang',
    Ripeness.overripe => 'Terlalu matang',
    Ripeness.rotten => 'Busuk',
  };

  /// Maps a model label to a [Ripeness]; null for unknown labels.
  static Ripeness? fromLabel(String label) {
    for (final value in Ripeness.values) {
      if (value.name == label) {
        return value;
      }
    }
    return null;
  }
}
