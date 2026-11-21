import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';

/// Centralized configuration for ripeness bucket splitting and unripe wait-day estimates.
/// All percentage thresholds are calibrated to the 3-class SVM output (`0.35 - 1.00`).
abstract final class RipenessRecipeConfig {
  /// Minimum `rotten` probability that shifts a `ripe` scan into `very_ripe`.
  static const double veryRipeMinRottenProb = 0.15;

  /// If `ripe` confidence drops below this value while `unripe` is low, treat as `very_ripe`.
  static const double veryRipeMaxRipeConfidence = 0.75;

  /// Maximum `unripe` probability allowed when classifying a borderline `ripe` as `very_ripe`.
  static const double veryRipeMaxUnripeProb = 0.10;

  /// Rule-based wait-day thresholds for `unripe` confidence (`0.35 - 1.00`).
  static const double unripeHighConfidenceThreshold = 0.80;
  static const double unripeMediumConfidenceThreshold = 0.60;

  /// Resolves the ripeness bucket for a `ripe` or `overripe` scan outcome.
  static RipenessBucket resolveRipeBucket(ScanSuccess outcome) {
    final normalized = outcome.ripenessLabel.trim().toLowerCase();
    if (normalized == 'overripe' || normalized == 'very_ripe') {
      return RipenessBucket.veryRipe;
    }
    if (normalized == 'unripe') {
      return RipenessBucket.unripe;
    }

    final probs = outcome.classProbabilities;
    // When the 4-class model explicitly includes `overripe`, trust its primary
    // `ripe` decision instead of shifting borderline `ripe` scans to `veryRipe`.
    if (probs != null && probs.containsKey('overripe')) {
      return RipenessBucket.ripe;
    }

    final rottenProb = probs?['rotten'] ?? 0.0;
    final unripeProb = probs?['unripe'] ?? 0.0;

    if (rottenProb >= veryRipeMinRottenProb) {
      return RipenessBucket.veryRipe;
    }
    if (outcome.ripenessConfidence < veryRipeMaxRipeConfidence &&
        unripeProb < veryRipeMaxUnripeProb) {
      return RipenessBucket.veryRipe;
    }
    return RipenessBucket.ripe;
  }

  /// Rule-based rough wait-day estimate for an `unripe` fruit.
  /// Returns an approximate day range string (labeled as an estimate in UI).
  static String estimateWaitDays(String fruitLabel, double unripeConfidence) {
    final normalizedFruit = fruitLabel.trim().toLowerCase();
    if (normalizedFruit == 'banana') {
      if (unripeConfidence >= unripeHighConfidenceThreshold) {
        return '4–5 hari';
      }
      if (unripeConfidence >= unripeMediumConfidenceThreshold) {
        return '2–3 hari';
      }
      return '1–2 hari';
    }

    // Generic fallback rule for other fruits when expanded in the future.
    if (unripeConfidence >= unripeHighConfidenceThreshold) {
      return '3–5 hari';
    }
    if (unripeConfidence >= unripeMediumConfidenceThreshold) {
      return '2–3 hari';
    }
    return '1–2 hari';
  }
}
