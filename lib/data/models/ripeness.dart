/// Ripeness classes produced by the ripeness model (labels_ripeness.txt).
enum Ripeness {
  unripe,
  ripe,
  overripe,
  rotten;

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
