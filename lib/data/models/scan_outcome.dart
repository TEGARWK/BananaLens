/// Result of scanning one image. Contract: INTEGRATION_CONTRACT.md section 3.
sealed class ScanOutcome {
  const ScanOutcome();
}

/// Both models returned a label above the confidence threshold.
final class ScanSuccess extends ScanOutcome {
  const ScanSuccess({
    required this.fruitLabel,
    required this.ripenessLabel,
    required this.fruitConfidence,
    required this.ripenessConfidence,
    this.classProbabilities,
  });

  final String fruitLabel;
  final String ripenessLabel;

  /// Probability in the range 0.0 - 1.0.
  final double fruitConfidence;
  final double ripenessConfidence;

  /// Optional breakdown of class probabilities (e.g. from SVM 4-class classifier).
  /// Key: class name ('unripe', 'ripe', 'overripe', 'rotten'), Value: 0.0 - 1.0.
  final Map<String, double>? classProbabilities;
}

/// Confidence was below the threshold; the UI asks the user to retake.
final class ScanUncertain extends ScanOutcome {
  const ScanUncertain();
}

/// Inference failed (bad image, model error, ...).
final class ScanFailure extends ScanOutcome {
  const ScanFailure(this.message);

  final String message;
}
