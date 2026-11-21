import 'dart:typed_data';

import 'on_device_image_preprocessor.dart';

/// Post-processing helpers for the on-device SVM: LIBSVM multiclass probability
/// coupling and pigment-based calibrations. Kept separate from the classifier so
/// model loading/inference stays small and readable.
abstract final class SvmPostProcessing {
  /// Ports Python `calibrate_4class_probs` to keep green (`unripe`) and
  /// spotted yellow (`overripe`) predictions aligned with the Colab evaluation.
  static void calibrate4ClassProbs(
    Map<String, double> probMap,
    PigmentRatios pigment,
  ) {
    if (pigment.activePixelCount < 50) return;

    final unripe = probMap['unripe'];
    final ripe = probMap['ripe'];
    final overripe = probMap['overripe'];
    final rotten = probMap['rotten'];
    if (unripe == null || ripe == null || overripe == null || rotten == null) {
      return;
    }

    final greenRatio = pigment.greenRatio;
    final yellowRatio = pigment.yellowRatio;
    final brownRatio = pigment.brownDarkRatio;

    if (greenRatio >= 0.25 && greenRatio > yellowRatio) {
      final floor = 0.72 + (0.22 * greenRatio);
      probMap['unripe'] = unripe > floor ? unripe : floor;
      probMap['ripe'] = ripe * 0.15;
      probMap['rotten'] = rotten * 0.15;
      _normalizeProbMap(probMap);
      return;
    }

    // Reinforce `rotten` when dark/brown decay covers >= 50% and SVM flags rot risk.
    if (greenRatio < 0.15 &&
        yellowRatio < 0.42 &&
        brownRatio >= 0.50 &&
        rotten < 0.70 &&
        (rotten >= 0.25 || ripe < 0.65)) {
      final decayFactor = ((brownRatio - 0.50) / 0.50).clamp(0.0, 1.0);
      final targetRotten = (0.68 + (0.24 * decayFactor)).clamp(0.68, 0.92);
      if (rotten < targetRotten) {
        final donor = ripe + overripe + 1e-7;
        final needed = targetRotten - rotten;
        probMap['rotten'] = rotten + needed;
        final nextRipe = ripe - needed * (ripe / donor);
        final nextOverripe = overripe - needed * (overripe / donor);
        probMap['ripe'] = nextRipe < 0.0 ? 0.0 : nextRipe;
        probMap['overripe'] = nextOverripe < 0.0 ? 0.0 : nextOverripe;
        _normalizeProbMap(probMap);
      }
      return;
    }

    final hasSpottedAmbiguity = (rotten + overripe) >= 0.20 || ripe < 0.70;
    if (hasSpottedAmbiguity &&
        greenRatio < 0.20 &&
        yellowRatio >= 0.18 &&
        brownRatio >= 0.15 &&
        brownRatio <= 0.68) {
      final spotFactor = (1.0 - ((brownRatio - 0.40).abs() / 0.28)).clamp(
        0.0,
        1.0,
      );
      final colorTarget = 0.62 + (0.28 * spotFactor);
      final targetOverripe = ((0.75 * colorTarget) + (0.25 * overripe)).clamp(
        0.0,
        0.92,
      );
      if (overripe < targetOverripe) {
        final donor = rotten + ripe + 1e-7;
        final needed = targetOverripe - overripe;
        probMap['overripe'] = overripe + needed;
        final nextRotten = rotten - needed * (rotten / donor);
        final nextRipe = ripe - needed * (ripe / donor);
        probMap['rotten'] = nextRotten < 0.0 ? 0.0 : nextRotten;
        probMap['ripe'] = nextRipe < 0.0 ? 0.0 : nextRipe;
        _normalizeProbMap(probMap);
      }
    }
  }

  static void _normalizeProbMap(Map<String, double> probMap) {
    double sum = 0.0;
    for (final value in probMap.values) {
      sum += value;
    }
    if (sum <= 0.0) return;
    for (final key in probMap.keys) {
      probMap[key] = (probMap[key] ?? 0.0) / sum;
    }
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
