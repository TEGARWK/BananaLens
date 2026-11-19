import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'on_device_image_preprocessor.dart';

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
  final Float32List pcaComponents; // [100 * 576] row-major
  final Float32List hsvScalerMean;
  final Float32List hsvScalerScale;
  final Float32List supportVectors; // [nSV * 130] row-major
  final Float32List dualCoef; // [(K-1) * nSV] row-major

  /// Parses packed `svm_pisang_meta.json` string and `svm_pisang_weights.bin` bytes.
  factory OnDeviceSvmClassifier.fromAssets({
    required String metaJson,
    required Uint8List weightsBytes,
  }) {
    final meta = jsonDecode(metaJson) as Map<String, dynamic>;
    final tensors = meta['tensors'] as Map<String, dynamic>;

    // Copy to a zero-aligned Uint8List before viewing as Float32List (little-endian).
    final aligned = Uint8List.fromList(weightsBytes);
    final allFloats = aligned.buffer.asFloat32List();

    Float32List sliceTensor(String name) {
      final info = tensors[name] as Map<String, dynamic>;
      final offset = (info['offset'] as num).toInt();
      final length = (info['length'] as num).toInt();
      return Float32List.sublistView(allFloats, offset, offset + length);
    }

    List<int> intList(String key) =>
        (meta[key] as List<dynamic>).map((e) => (e as num).toInt()).toList();
    List<double> doubleList(String key) =>
        (meta[key] as List<dynamic>).map((e) => (e as num).toDouble()).toList();

    return OnDeviceSvmClassifier(
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
  }

  /// Runs StandardScaler + PCA + RBF kernel + LIBSVM pairwise coupling probabilities,
  /// optionally applying chlorophyll post-processing calibration for unripe green bananas.
  SvmPrediction predict(
    Float32List cnn576,
    Float32List hsv30, {
    PigmentRatios? pigmentRatios,
  }) {
    const cnnDim = 576;
    const pcaDim = 100;
    const hsvDim = 30;
    const totalDim = pcaDim + hsvDim; // 130

    // 1. Scale CNN 576 & subtract PCA mean
    final cnnCentered = Float64List(cnnDim);
    for (int i = 0; i < cnnDim; i++) {
      final scaled = (cnn576[i] - cnnScalerMean[i]) / cnnScalerScale[i];
      cnnCentered[i] = scaled - pcaMean[i];
    }

    // 2. Project via PCA components [100 x 576] and concatenate scaled HSV [30]
    final x130 = Float64List(totalDim);
    for (int c = 0; c < pcaDim; c++) {
      final rowOffset = c * cnnDim;
      double dot = 0.0;
      for (int i = 0; i < cnnDim; i++) {
        dot += cnnCentered[i] * pcaComponents[rowOffset + i];
      }
      x130[c] = dot;
    }
    for (int i = 0; i < hsvDim; i++) {
      x130[pcaDim + i] = (hsv30[i] - hsvScalerMean[i]) / hsvScalerScale[i];
    }

    // 3. Evaluate RBF kernel K(x, sv_i) = exp(-gamma * ||x - sv_i||^2)
    final numClasses = classNames.length;
    int totalSv = 0;
    for (final count in nSupport) {
      totalSv += count;
    }

    final kernel = Float64List(totalSv);
    double maxKernel = 0.0;
    for (int i = 0; i < totalSv; i++) {
      final svOffset = i * totalDim;
      double distSq = 0.0;
      for (int j = 0; j < totalDim; j++) {
        final d = x130[j] - supportVectors[svOffset + j];
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
    final probs = _multiclassProbability(numClasses, pairwise);

    final probMap = <String, double>{};
    for (int i = 0; i < numClasses; i++) {
      probMap[classNames[i]] = probs[i].clamp(0.0, 1.0);
    }

    if (pigmentRatios != null) {
      _applyChlorophyllCalibration(probMap, pigmentRatios);
      _applyOverripeYellowCalibration(probMap, pigmentRatios);
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

  /// Reinforces `unripe` over `ripe` when explicit chlorophyll green pigment
  /// covers >= 30% of the fruit body and dominates yellow and brown/dark pixels.
  static void _applyChlorophyllCalibration(
    Map<String, double> probMap,
    PigmentRatios pigment,
  ) {
    if (pigment.activePixelCount < 50) return;
    if (pigment.greenRatio < 0.30) return;
    if (pigment.greenRatio <= pigment.yellowRatio ||
        pigment.greenRatio <= pigment.brownDarkRatio) {
      return;
    }

    final svmUnripe = probMap['unripe'];
    final svmRipe = probMap['ripe'];
    if (svmUnripe == null || svmRipe == null) return;

    final pairBudget = svmUnripe + svmRipe;
    if (pairBudget <= 1e-6) return;

    final svmUnripeShare = svmUnripe / pairBudget;
    final colorGreenShare =
        pigment.greenRatio / (pigment.greenRatio + pigment.yellowRatio + 1e-6);
    final blendedUnripeShare =
        (0.20 * svmUnripeShare) + (0.80 * colorGreenShare);
    final calibratedUnripe = (pairBudget * blendedUnripeShare).clamp(
      0.0,
      pairBudget,
    );

    if (calibratedUnripe > svmUnripe) {
      probMap['unripe'] = calibratedUnripe;
      probMap['ripe'] = (pairBudget - calibratedUnripe).clamp(0.0, pairBudget);
    }

    // Dampens false-positive `rotten` caused by inter-fruit shadows or dark
    // backgrounds on green banana bunches when chlorophyll clearly dominates brown/dark pixels.
    final svmRotten = probMap['rotten'];
    if (svmRotten != null &&
        svmRotten > 0.0 &&
        pigment.greenRatio >= 0.35 &&
        pigment.greenRatio >= pigment.brownDarkRatio * 1.8) {
      final greenVsBrown =
          (pigment.greenRatio /
                  (pigment.greenRatio + pigment.brownDarkRatio + 1e-6))
              .clamp(0.0, 1.0);
      final rottenShift = (svmRotten * (0.75 * greenVsBrown)).clamp(
        0.0,
        svmRotten,
      );
      probMap['rotten'] = (svmRotten - rottenShift).clamp(0.0, 1.0);
      probMap['unripe'] = ((probMap['unripe'] ?? 0.0) + rottenShift).clamp(
        0.0,
        1.0,
      );
    }
  }

  /// Keeps yellow bananas with sugar spots (`overripe`) in `ripe` instead of
  /// `rotten` when bright yellow peel still dominates brown/dark areas.
  static void _applyOverripeYellowCalibration(
    Map<String, double> probMap,
    PigmentRatios pigment,
  ) {
    if (pigment.activePixelCount < 50) return;
    if (pigment.greenRatio >= 0.30) return;
    if (pigment.yellowRatio < 0.50) return;
    if (pigment.yellowRatio < pigment.brownDarkRatio * 1.6) return;

    final svmRipe = probMap['ripe'];
    final svmRotten = probMap['rotten'];
    if (svmRipe == null || svmRotten == null) return;
    if (svmRotten <= svmRipe) return;

    final yellowDominance =
        (pigment.yellowRatio /
                (pigment.yellowRatio + pigment.brownDarkRatio + 1e-6))
            .clamp(0.0, 1.0);
    final shift = (svmRotten * (0.60 * yellowDominance)).clamp(0.0, svmRotten);

    probMap['rotten'] = (svmRotten - shift).clamp(0.0, 1.0);
    probMap['ripe'] = (svmRipe + shift).clamp(0.0, 1.0);
  }

  static Float64List _multiclassProbability(int k, List<Float64List> r) {
    final q = List<Float64List>.generate(k, (_) => Float64List(k));
    final p = Float64List(k);
    final qp = Float64List(k);
    final eps = 0.005 / k;

    for (int t = 0; t < k; t++) {
      p[t] = 1.0 / k;
      q[t][t] = 0.0;
      for (int j = 0; j < t; j++) {
        q[t][t] += r[j][t] * r[j][t];
        q[t][j] = q[j][t];
      }
      for (int j = t + 1; j < k; j++) {
        q[t][t] += r[j][t] * r[j][t];
        q[t][j] = -r[j][t] * r[t][j];
      }
    }

    for (int iter = 0; iter < 100; iter++) {
      double pQp = 0.0;
      for (int t = 0; t < k; t++) {
        double rowDot = 0.0;
        for (int j = 0; j < k; j++) {
          rowDot += q[t][j] * p[j];
        }
        qp[t] = rowDot;
        pQp += p[t] * rowDot;
      }

      double maxError = 0.0;
      for (int t = 0; t < k; t++) {
        final error = (qp[t] - pQp).abs();
        if (error > maxError) maxError = error;
      }
      if (maxError < eps) break;

      for (int t = 0; t < k; t++) {
        final diff = (-qp[t] + pQp) / q[t][t];
        p[t] += diff;
        pQp =
            (pQp + diff * (diff * q[t][t] + 2.0 * qp[t])) /
            (1.0 + diff) /
            (1.0 + diff);
        for (int j = 0; j < k; j++) {
          qp[j] = (qp[j] + diff * q[t][j]) / (1.0 + diff);
          p[j] /= (1.0 + diff);
        }
      }
    }
    return p;
  }
}
