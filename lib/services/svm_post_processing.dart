import 'dart:typed_data';

import 'on_device_image_preprocessor.dart';

/// Post-processing helpers for the on-device SVM: LIBSVM multiclass probability
/// coupling and pigment-based calibrations. Kept separate from the classifier so
/// model loading/inference stays small and readable.
abstract final class SvmPostProcessing {
  /// Reinforces `unripe` over `ripe` when explicit chlorophyll green pigment
  /// covers >= 30% of the fruit body and dominates yellow and brown/dark pixels.
  static void applyChlorophyllCalibration(
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

  /// Keeps yellow bananas (clean yellow on dark backgrounds -> `ripe`, or yellow
  /// with sugar spots -> `overripe`/`ripe`) from being misclassified as `rotten`
  /// when bright yellow peel clearly dominates brown/dark areas.
  static void applyOverripeYellowCalibration(
    Map<String, double> probMap,
    PigmentRatios pigment,
  ) {
    if (pigment.activePixelCount < 50) return;
    if (pigment.greenRatio >= 0.30) return;
    if (pigment.yellowRatio < 0.42) return;
    if (pigment.yellowRatio < pigment.brownDarkRatio * 1.4) return;

    // Clean yellow peel (or bright yellow on dark asphalt where background shadows
    // inflate brownDark slightly) belongs to `ripe`; noticeable sugar spots belong to `overripe`.
    final isCleanYellow =
        pigment.brownDarkRatio < 0.18 ||
        (pigment.yellowRatio >= 0.60 && pigment.brownDarkRatio < 0.35);
    final targetClass = (!isCleanYellow && probMap.containsKey('overripe'))
        ? 'overripe'
        : 'ripe';
    final targetProb = probMap[targetClass];
    final svmRotten = probMap['rotten'];
    if (targetProb == null || svmRotten == null) return;
    if (svmRotten <= targetProb) return;

    final yellowDominance =
        (pigment.yellowRatio /
                (pigment.yellowRatio + pigment.brownDarkRatio + 1e-6))
            .clamp(0.0, 1.0);
    final shiftFactor = isCleanYellow ? 0.70 : 0.60;
    final shift = (svmRotten * (shiftFactor * yellowDominance)).clamp(
      0.0,
      svmRotten,
    );

    probMap['rotten'] = (svmRotten - shift).clamp(0.0, 1.0);
    probMap[targetClass] = (targetProb + shift).clamp(0.0, 1.0);
  }

  /// Wu, Lin & Weng (2004) multiclass pairwise coupling solver (LIBSVM port).
  static Float64List multiclassProbability(int k, List<Float64List> r) {
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
