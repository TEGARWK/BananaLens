import 'on_device_svm_classifier.dart';

/// Shape consistency checks so the classifier always follows the trained model
/// (CNN / PCA / HSV / support-vector sizes come from tensors, never hardcoded).
extension SvmShapeValidation on OnDeviceSvmClassifier {
  /// Throws [FormatException] when trained tensors disagree on dimensions.
  void validateShapes() {
    final k = classNames.length;
    final pairs = (k * (k - 1)) ~/ 2;
    final nSv = totalSupportVectors;

    void check(bool ok, String message) {
      if (!ok) throw FormatException('Model SVM tidak konsisten: $message');
    }

    check(k >= 2, 'jumlah kelas < 2');
    check(nSupport.length == k, 'n_support (${nSupport.length}) != kelas ($k)');
    check(
      intercept.length == pairs &&
          probA.length == pairs &&
          probB.length == pairs,
      'intercept/probA/probB harus $pairs pasangan kelas',
    );
    check(
      cnnScalerScale.length == cnnDim && pcaMean.length == cnnDim,
      'cnn_scaler_scale/pca_mean harus $cnnDim dimensi',
    );
    check(
      pcaComponents.length % cnnDim == 0 && pcaDim > 0,
      'pca_components (${pcaComponents.length}) bukan kelipatan $cnnDim',
    );
    check(
      hsvScalerScale.length == hsvDim,
      'hsv_scaler_scale harus $hsvDim dimensi',
    );
    check(
      supportVectors.length == nSv * featureDim,
      'support_vectors (${supportVectors.length}) != $nSv x $featureDim',
    );
    check(
      dualCoef.length == (k - 1) * nSv,
      'dual_coef (${dualCoef.length}) != ${k - 1} x $nSv',
    );
  }
}
