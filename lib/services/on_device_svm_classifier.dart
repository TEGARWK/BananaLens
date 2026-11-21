import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'on_device_image_preprocessor.dart';
import 'svm_model_validation.dart';
import 'svm_post_processing.dart';
import 'svm_prediction.dart';

export 'svm_prediction.dart';

/// Pure-Dart implementation of scikit-learn StandardScaler + PCA + LIBSVM RBF + Platt coupling.
/// All fields are isolate-safe primitive/typed-data buffers loaded once from assets.
class OnDeviceSvmClassifier {
  OnDeviceSvmClassifier({
    required this.classNames,
    required this.hsvWeight,
    required this.gamma,
    required this.nSupport,
    required this.intercept,
    required this.probA,
    required this.probB,
    required this.cnnScalerMean,
    required this.cnnScalerScale,
    required this.pcaMean,
    required this.pcaComponents,
    required this.hsvScalerMean,
    required this.hsvScalerScale,
    required this.supportVectors,
    required this.dualCoef,
  });

  final List<String> classNames;
  final double hsvWeight;
  final double gamma;
  final List<int> nSupport;
  final List<double> intercept;
  final List<double> probA;
  final List<double> probB;

  final Float32List cnnScalerMean;
  final Float32List cnnScalerScale;
  final Float32List pcaMean;
  final Float32List pcaComponents; // [pcaDim * cnnDim] row-major
  final Float32List hsvScalerMean;
  final Float32List hsvScalerScale;
  final Float32List supportVectors; // [nSV * (pcaDim + hsvDim)] row-major
  final Float32List dualCoef; // [(K-1) * nSV] row-major

  /// CNN feature size, read from the trained `cnn_scaler_mean` tensor.
  int get cnnDim => cnnScalerMean.length;

  /// Masked HSV feature size, read from the trained `hsv_scaler_mean` tensor.
  int get hsvDim => hsvScalerMean.length;

  /// Number of PCA components, derived from `pca_components` = [pcaDim x cnnDim].
  int get pcaDim => pcaComponents.length ~/ cnnDim;

  /// Final SVM input size (PCA-projected CNN + scaled HSV).
  int get featureDim => pcaDim + hsvDim;

  /// Total support vectors across all classes.
  int get totalSupportVectors => nSupport.fold(0, (a, b) => a + b);

  /// Parses packed `svm_pisang_meta.json` string and `svm_pisang_weights.bin` bytes.
  /// Every dimension (CNN, PCA, HSV, support vectors) follows the trained model;
  /// throws [FormatException] when tensors are inconsistent with each other.
  factory OnDeviceSvmClassifier.fromAssets({
    required String metaJson,
    required Uint8List weightsBytes,
  }) {
    final meta = jsonDecode(metaJson) as Map<String, dynamic>;
    final tensors = meta['tensors'] as Map<String, dynamic>;

    if (weightsBytes.length % 4 != 0) {
      throw const FormatException(
        'Bobot model SVM rusak: ukuran file bukan kelipatan float32.',
      );
    }

    // Copy to a zero-aligned Uint8List before viewing as Float32List (little-endian).
    final aligned = Uint8List.fromList(weightsBytes);
    final allFloats = aligned.buffer.asFloat32List();

    Float32List sliceTensor(String name) {
      final info = tensors[name];
      if (info is! Map<String, dynamic>) {
        throw FormatException('Tensor "$name" tidak ada di metadata model.');
      }
      final offset = (info['offset'] as num).toInt();
      final length = (info['length'] as num).toInt();
      if (offset < 0 || length <= 0 || offset + length > allFloats.length) {
        throw FormatException(
          'Tensor "$name" di luar batas file bobot '
          '(offset=$offset, length=$length, total=${allFloats.length}).',
        );
      }
      return Float32List.sublistView(allFloats, offset, offset + length);
    }

    List<int> intList(String key) =>
        (meta[key] as List<dynamic>).map((e) => (e as num).toInt()).toList();
    List<double> doubleList(String key) =>
        (meta[key] as List<dynamic>).map((e) => (e as num).toDouble()).toList();

    final classifier = OnDeviceSvmClassifier(
      classNames: (meta['class_names'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(growable: false),
      hsvWeight: (meta['hsv_weight'] as num).toDouble(),
      gamma: (meta['gamma'] as num).toDouble(),
      nSupport: intList('n_support'),
      intercept: doubleList('intercept'),
      probA: doubleList('probA'),
      probB: doubleList('probB'),
      cnnScalerMean: sliceTensor('cnn_scaler_mean'),
      cnnScalerScale: sliceTensor('cnn_scaler_scale'),
      pcaMean: sliceTensor('pca_mean'),
      pcaComponents: sliceTensor('pca_components'),
      hsvScalerMean: sliceTensor('hsv_scaler_mean'),
      hsvScalerScale: sliceTensor('hsv_scaler_scale'),
      supportVectors: sliceTensor('support_vectors'),
      dualCoef: sliceTensor('dual_coef'),
    );
    classifier.validateShapes();
    return classifier;
  }

  /// Runs StandardScaler + PCA + RBF kernel + LIBSVM pairwise coupling probabilities,
  /// optionally applying chlorophyll post-processing calibration for unripe green bananas.
  SvmPrediction predict(
    Float32List cnnFeatures,
    Float32List hsvFeatures, {
    PigmentRatios? pigmentRatios,
  }) {
    // All dimensions follow the trained model tensors (no hardcoded sizes).
    final cnnDim = this.cnnDim;
    final pcaDim = this.pcaDim;
    final hsvDim = this.hsvDim;
    final totalDim = featureDim;
    if (cnnFeatures.length != cnnDim || hsvFeatures.length != hsvDim) {
      throw FormatException(
        'Ukuran fitur tidak cocok dengan model: CNN ${cnnFeatures.length}/$cnnDim, '
        'HSV ${hsvFeatures.length}/$hsvDim.',
      );
    }

    // 1. Scale CNN features & subtract PCA mean
    final cnnCentered = Float64List(cnnDim);
    for (int i = 0; i < cnnDim; i++) {
      final scaled = (cnnFeatures[i] - cnnScalerMean[i]) / cnnScalerScale[i];
      cnnCentered[i] = scaled - pcaMean[i];
    }

    // 2. Project via PCA components [pcaDim x cnnDim] and concatenate scaled HSV
    final xCombined = Float64List(totalDim);
    for (int c = 0; c < pcaDim; c++) {
      final rowOffset = c * cnnDim;
      double dot = 0.0;
      for (int i = 0; i < cnnDim; i++) {
        dot += cnnCentered[i] * pcaComponents[rowOffset + i];
      }
      xCombined[c] = dot;
    }
    for (int i = 0; i < hsvDim; i++) {
      xCombined[pcaDim + i] =
          (hsvFeatures[i] - hsvScalerMean[i]) / hsvScalerScale[i];
    }

    // 3. Evaluate RBF kernel K(x, sv_i) = exp(-gamma * ||x - sv_i||^2)
    final numClasses = classNames.length;
    final totalSv = totalSupportVectors;

    final kernel = Float64List(totalSv);
    double maxKernel = 0.0;
    for (int i = 0; i < totalSv; i++) {
      final svOffset = i * totalDim;
      double distSq = 0.0;
      for (int j = 0; j < totalDim; j++) {
        final d = xCombined[j] - supportVectors[svOffset + j];
        distSq += d * d;
      }
      final kVal = math.exp(-gamma * distSq);
      kernel[i] = kVal;
      if (kVal > maxKernel) {
        maxKernel = kVal;
      }
    }

    // 4. LIBSVM pairwise decision values
    final start = List<int>.filled(numClasses, 0);
    for (int i = 1; i < numClasses; i++) {
      start[i] = start[i - 1] + nSupport[i - 1];
    }

    final numPairs = (numClasses * (numClasses - 1)) ~/ 2;
    final decValues = Float64List(numPairs);
    int p = 0;
    for (int i = 0; i < numClasses; i++) {
      for (int j = i + 1; j < numClasses; j++) {
        final si = start[i];
        final ci = nSupport[i];
        final sj = start[j];
        final cj = nSupport[j];

        final coefOffsetJ = (j - 1) * totalSv;
        final coefOffsetI = i * totalSv;

        double sum = 0.0;
        for (int k = 0; k < ci; k++) {
          sum += dualCoef[coefOffsetJ + si + k] * kernel[si + k];
        }
        for (int k = 0; k < cj; k++) {
          sum += dualCoef[coefOffsetI + sj + k] * kernel[sj + k];
        }
        decValues[p] = sum + intercept[p];
        p++;
      }
    }

    // 5. Platt sigmoid calibration -> pairwise probability matrix
    final pairwise = List<Float64List>.generate(
      numClasses,
      (_) => Float64List(numClasses),
    );
    const minProb = 1e-7;
    p = 0;
    for (int i = 0; i < numClasses; i++) {
      for (int j = i + 1; j < numClasses; j++) {
        final fApB = decValues[p] * probA[p] + probB[p];
        double prob;
        if (fApB >= 0) {
          prob = math.exp(-fApB) / (1.0 + math.exp(-fApB));
        } else {
          prob = 1.0 / (1.0 + math.exp(fApB));
        }
        prob = prob.clamp(minProb, 1.0 - minProb);
        pairwise[i][j] = prob;
        pairwise[j][i] = 1.0 - prob;
        p++;
      }
    }

    // 6. Wu, Lin & Weng (2004) multiclass pairwise coupling solver
    final probs = SvmPostProcessing.multiclassProbability(numClasses, pairwise);

    final probMap = <String, double>{};
    for (int i = 0; i < numClasses; i++) {
      probMap[classNames[i]] = probs[i].clamp(0.0, 1.0);
    }

    if (pigmentRatios != null) {
      SvmPostProcessing.calibrate4ClassProbs(probMap, pigmentRatios);
    }

    String bestClass = classNames.first;
    double bestProb = probMap[bestClass] ?? 0.0;
    for (final entry in probMap.entries) {
      if (entry.value > bestProb) {
        bestProb = entry.value;
        bestClass = entry.key;
      }
    }

    return SvmPrediction(
      predictedClass: bestClass,
      confidence: bestProb.clamp(0.0, 1.0),
      probabilities: probMap,
      maxKernelSimilarity: maxKernel.clamp(0.0, 1.0),
    );
  }
}
