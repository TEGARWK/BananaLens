/// Prediction output from the on-device hybrid PCA + RBF SVM pipeline.
class SvmPrediction {
  const SvmPrediction({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    this.maxKernelSimilarity = 1.0,
  });

  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;

  /// Highest RBF kernel similarity `max_i exp(-gamma * ||x - sv_i||^2)` across
  /// all banana support vectors; useful for out-of-distribution (non-banana) checks.
  final double maxKernelSimilarity;
}
