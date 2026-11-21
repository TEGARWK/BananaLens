import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/services/on_device_image_preprocessor.dart';
import 'package:fruitlens/services/on_device_svm_classifier.dart';
import 'package:fruitlens/services/svm_post_processing.dart';

/// Builds a tiny synthetic SVM model (meta JSON + float32 bytes) with arbitrary
/// CNN / PCA / HSV sizes to prove the classifier never relies on hardcoded dims.
({String meta, Uint8List bytes}) _buildSyntheticModel({
  required int cnnDim,
  required int pcaDim,
  required int hsvDim,
  List<String> classNames = const ['ripe', 'rotten', 'unripe'],
  int svPerClass = 2,
  int? overrideSupportVectorLength,
}) {
  final k = classNames.length;
  final pairs = k * (k - 1) ~/ 2;
  final nSv = svPerClass * k;
  final featureDim = pcaDim + hsvDim;

  final tensors = <String, Map<String, int>>{};
  final values = <double>[];
  void add(String name, int length, double Function(int i) fill) {
    tensors[name] = {'offset': values.length, 'length': length};
    for (int i = 0; i < length; i++) {
      values.add(fill(i));
    }
  }

  add('cnn_scaler_mean', cnnDim, (_) => 0.0);
  add('cnn_scaler_scale', cnnDim, (_) => 1.0);
  add('pca_mean', cnnDim, (_) => 0.0);
  add('pca_components', pcaDim * cnnDim, (i) => ((i % 7) - 3) / 10.0);
  add('hsv_scaler_mean', hsvDim, (_) => 0.0);
  add('hsv_scaler_scale', hsvDim, (_) => 1.0);
  add(
    'support_vectors',
    overrideSupportVectorLength ?? nSv * featureDim,
    (i) => ((i ~/ featureDim) % k) * 1.0 + (i % 3) * 0.1,
  );
  add('dual_coef', (k - 1) * nSv, (i) => i.isEven ? 0.05 : -0.05);

  final meta = jsonEncode({
    'class_names': classNames,
    'hsv_weight': 2.5,
    'gamma': 0.01,
    'n_support': List<int>.filled(k, svPerClass),
    'intercept': List<double>.filled(pairs, 0.0),
    'probA': List<double>.filled(pairs, -1.0),
    'probB': List<double>.filled(pairs, 0.0),
    'tensors': tensors,
  });
  final bytes = Float32List.fromList(values).buffer.asUint8List();
  return (meta: meta, bytes: bytes);
}

void main() {
  group('OnDeviceSvmClassifier follows trained model dimensions', () {
    test('real bundled model: dims are read from tensors (PCA 100)', () {
      final metaJson = File(
        'assets/models/svm_pisang_meta.json',
      ).readAsStringSync();
      final bytes = File(
        'assets/models/svm_pisang_weights.bin',
      ).readAsBytesSync();

      final c = OnDeviceSvmClassifier.fromAssets(
        metaJson: metaJson,
        weightsBytes: bytes,
      );

      expect(c.classNames, ['overripe', 'ripe', 'rotten', 'unripe']);
      expect(c.cnnDim, 576);
      expect(c.pcaDim, 60);
      expect(c.hsvDim, 30);
      expect(c.featureDim, 90);
      expect(c.totalSupportVectors, 3899);
    });

    test('real bundled model: every tensor min/max matches metadata', () {
      final meta =
          jsonDecode(
                File('assets/models/svm_pisang_meta.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final bytes = File(
        'assets/models/svm_pisang_weights.bin',
      ).readAsBytesSync();
      final floats = Uint8List.fromList(bytes).buffer.asFloat32List();
      final tensors = meta['tensors'] as Map<String, dynamic>;

      for (final entry in tensors.entries) {
        final info = entry.value as Map<String, dynamic>;
        if (!info.containsKey('min')) continue;
        final offset = (info['offset'] as num).toInt();
        final length = (info['length'] as num).toInt();
        final slice = floats.sublist(offset, offset + length);
        final minV = slice.reduce((a, b) => a < b ? a : b);
        final maxV = slice.reduce((a, b) => a > b ? a : b);
        expect(
          minV,
          closeTo((info['min'] as num).toDouble(), 1e-5),
          reason: '${entry.key} min',
        );
        expect(
          maxV,
          closeTo((info['max'] as num).toDouble(), 1e-5),
          reason: '${entry.key} max',
        );
      }
    });

    for (final pca in [60, 100]) {
      test('synthetic model with PCA $pca predicts valid probabilities', () {
        final model = _buildSyntheticModel(cnnDim: 16, pcaDim: pca, hsvDim: 4);
        final c = OnDeviceSvmClassifier.fromAssets(
          metaJson: model.meta,
          weightsBytes: model.bytes,
        );

        expect(c.pcaDim, pca);
        expect(c.featureDim, pca + 4);

        final pred = c.predict(Float32List(16), Float32List(4));
        final sum = pred.probabilities.values.reduce((a, b) => a + b);
        expect(sum, closeTo(1.0, 1e-3));
        expect(pred.probabilities.keys, {'ripe', 'rotten', 'unripe'});
      });
    }

    test('non-576 CNN and non-30 HSV sizes also work (no hardcode)', () {
      final model = _buildSyntheticModel(cnnDim: 8, pcaDim: 3, hsvDim: 5);
      final c = OnDeviceSvmClassifier.fromAssets(
        metaJson: model.meta,
        weightsBytes: model.bytes,
      );
      expect(c.cnnDim, 8);
      expect(c.hsvDim, 5);
      final pred = c.predict(Float32List(8), Float32List(5));
      expect(pred.confidence, inInclusiveRange(0.0, 1.0));
    });

    test('inconsistent support_vectors length throws FormatException', () {
      final model = _buildSyntheticModel(
        cnnDim: 8,
        pcaDim: 3,
        hsvDim: 5,
        overrideSupportVectorLength: 10,
      );
      expect(
        () => OnDeviceSvmClassifier.fromAssets(
          metaJson: model.meta,
          weightsBytes: model.bytes,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('tensor offset beyond weights file throws FormatException', () {
      final model = _buildSyntheticModel(cnnDim: 8, pcaDim: 3, hsvDim: 5);
      final truncated = Uint8List.sublistView(model.bytes, 0, 64);
      expect(
        () => OnDeviceSvmClassifier.fromAssets(
          metaJson: model.meta,
          weightsBytes: truncated,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('predict rejects feature vectors that do not match the model', () {
      final model = _buildSyntheticModel(cnnDim: 8, pcaDim: 3, hsvDim: 5);
      final c = OnDeviceSvmClassifier.fromAssets(
        metaJson: model.meta,
        weightsBytes: model.bytes,
      );
      expect(
        () => c.predict(Float32List(576), Float32List(30)),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'calibrate4ClassProbs boosts unripe when greenRatio >= 0.25 and > yellowRatio',
      () {
        final probs = <String, double>{
          'unripe': 0.22,
          'ripe': 0.65,
          'overripe': 0.03,
          'rotten': 0.10,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.70,
            yellowRatio: 0.10,
            brownDarkRatio: 0.20,
            activePixelCount: 4000,
          ),
        );
        expect(probs['unripe']!, greaterThan(0.80));
        expect(probs['ripe']!, lessThan(0.15));
      },
    );

    test(
      'calibrate4ClassProbs boosts spotted yellow banana into overripe proportionally',
      () {
        final probs = <String, double>{
          'unripe': 0.002,
          'ripe': 0.35,
          'overripe': 0.10,
          'rotten': 0.548,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.02,
            yellowRatio: 0.35,
            brownDarkRatio: 0.40,
            activePixelCount: 4000,
          ),
        );
        expect(probs['overripe']!, closeTo(0.70, 1e-4));
        expect(probs['overripe']!, greaterThan(probs['rotten']!));
      },
    );

    test(
      'calibrate4ClassProbs keeps confident ripe banana on wooden/cream background as ripe',
      () {
        final probs = <String, double>{
          'unripe': 0.01,
          'ripe': 0.88,
          'overripe': 0.08,
          'rotten': 0.03,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.01,
            yellowRatio: 0.45,
            brownDarkRatio: 0.38,
            activePixelCount: 4000,
          ),
        );
        expect(probs['ripe'], closeTo(0.88, 1e-6));
        expect(probs['overripe'], closeTo(0.08, 1e-6));
      },
    );

    test(
      'calibrate4ClassProbs reinforces rotten when dark decay dominates and SVM is uncertain',
      () {
        final probs = <String, double>{
          'unripe': 0.01,
          'ripe': 0.57,
          'overripe': 0.08,
          'rotten': 0.34,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.01,
            yellowRatio: 0.18,
            brownDarkRatio: 0.72,
            activePixelCount: 4000,
          ),
        );
        expect(probs['rotten']!, greaterThan(0.70));
        expect(probs['rotten']!, greaterThan(probs['ripe']!));
      },
    );

    test(
      'calibrate4ClassProbs leaves truly dark rotten banana (> 68% brown) untouched',
      () {
        final probs = <String, double>{
          'unripe': 0.009,
          'ripe': 0.175,
          'overripe': 0.079,
          'rotten': 0.737,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.01,
            yellowRatio: 0.15,
            brownDarkRatio: 0.78,
            activePixelCount: 4000,
          ),
        );
        expect(probs['rotten'], closeTo(0.737, 1e-6));
      },
    );

    test(
      'calibrate4ClassProbs leaves clean yellow ripe banana (< 15% brown) untouched',
      () {
        final probs = <String, double>{
          'unripe': 0.01,
          'ripe': 0.85,
          'overripe': 0.10,
          'rotten': 0.04,
        };
        SvmPostProcessing.calibrate4ClassProbs(
          probs,
          const PigmentRatios(
            greenRatio: 0.02,
            yellowRatio: 0.88,
            brownDarkRatio: 0.10,
            activePixelCount: 4000,
          ),
        );
        expect(probs['ripe'], closeTo(0.85, 1e-6));
      },
    );
  });
}
