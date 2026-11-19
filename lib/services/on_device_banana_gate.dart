import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Result of Stage-1 ImageNet Banana Gate classification.
class BananaGateResult {
  const BananaGateResult({
    required this.isBanana,
    required this.bananaProbability,
    required this.bananaRank,
    required this.topClassIndex,
    required this.topProbability,
  });

  final bool isBanana;
  final double bananaProbability;
  final int bananaRank;
  final int topClassIndex;
  final double topProbability;
}

/// Abstract contract for Stage-1 on-device banana object verification.
abstract class BananaGate {
  Future<BananaGateResult> checkBanana(Uint8List rgb224Bytes);
  Future<void> dispose();
}

/// Stage-1 on-device banana verifier powered by Google's official quantized
/// ImageNet EfficientNet-Lite0 TFLite model (1000 classes, class #954 = banana).
/// Runs inside a background [IsolateInterpreter] so the UI thread never blocks.
class TfliteImageNetBananaGate implements BananaGate {
  TfliteImageNetBananaGate({this.assetPath = defaultAssetPath});

  static const String defaultAssetPath =
      'assets/models/imagenet_banana_gate.tflite';

  /// ImageNet 1000-class index for `banana` (verified from embedded metadata).
  static const int bananaClassIndex = 954;

  /// Acceptance thresholds balancing strict non-banana rejection (mango, avocado,
  /// orange, eggplant) with high recall on bunches, green, and rotten bananas.
  static const double minDirectBananaProbability = 0.08;
  static const int maxTopRankForBanana = 5;
  static const double minTopRankBananaProbability = 0.03;

  /// When banana is only in top-5 (not >= 0.08), require it to be at least 25%
  /// as confident as the top-1 class so clear non-bananas like avocado
  /// (topClass=acorn squash 0.38 vs banana 0.027 -> ratio 0.07) are rejected,
  /// while ambiguous rotten bananas (topClass 0.074 vs banana 0.035 -> ratio 0.47) pass.
  static const double minTopRankRelativeRatio = 0.25;

  final String assetPath;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  Future<void>? _initFuture;
  TensorType _inputType = TensorType.uint8;
  TensorType _outputType = TensorType.uint8;
  int _outputLength = 1000;
  double _outputScale = 1.0 / 255.0;
  int _outputZeroPoint = 0;

  Future<void> _ensureLoaded() async {
    if (_isolateInterpreter != null) return;
    _initFuture ??= () async {
      final options = InterpreterOptions()..threads = 2;
      final interpreter = await Interpreter.fromAsset(
        assetPath,
        options: options,
      );
      final inTensor = interpreter.getInputTensor(0);
      final outTensor = interpreter.getOutputTensor(0);
      _inputType = inTensor.type;
      _outputType = outTensor.type;
      _outputLength = outTensor.shape.reduce((a, b) => a * b);
      final params = outTensor.params;
      _outputScale = params.scale > 0 ? params.scale : (1.0 / 255.0);
      _outputZeroPoint = params.zeroPoint;

      debugPrint(
        'TfliteImageNetBananaGate loaded -> in=${inTensor.shape}(${inTensor.type}), '
        'out=${outTensor.shape}(${outTensor.type}, scale=$_outputScale, zp=$_outputZeroPoint)',
      );

      _interpreter = interpreter;
      _isolateInterpreter = await IsolateInterpreter.create(
        address: interpreter.address,
        debugName: 'BananaLensImageNetGate',
      );
    }();
    await _initFuture;
  }

  @override
  Future<BananaGateResult> checkBanana(Uint8List rgb224Bytes) async {
    await _ensureLoaded();
    final iso = _isolateInterpreter!;

    final Object inputBuffer;
    if (_inputType == TensorType.float32) {
      final floatInput = Float32List(rgb224Bytes.length);
      for (int i = 0; i < rgb224Bytes.length; i++) {
        floatInput[i] = (rgb224Bytes[i] - 127.0) / 128.0;
      }
      inputBuffer = floatInput.buffer.asUint8List();
    } else {
      inputBuffer = rgb224Bytes;
    }

    final probs = List<double>.filled(_outputLength, 0.0);
    if (_outputType == TensorType.float32) {
      final outFloat = Float32List(_outputLength);
      await iso.run(inputBuffer, outFloat.buffer);
      for (int i = 0; i < _outputLength; i++) {
        probs[i] = outFloat[i];
      }
    } else {
      final outUint8 = Uint8List(_outputLength);
      await iso.run(inputBuffer, outUint8.buffer);
      for (int i = 0; i < _outputLength; i++) {
        probs[i] = ((outUint8[i] - _outputZeroPoint) * _outputScale).clamp(
          0.0,
          1.0,
        );
      }
    }

    return evaluateProbabilities(probs);
  }

  /// Pure-Dart evaluation of 1000-class ImageNet probabilities for unit testing.
  @visibleForTesting
  static BananaGateResult evaluateProbabilities(List<double> probs) {
    if (probs.length <= bananaClassIndex) {
      return const BananaGateResult(
        isBanana: true,
        bananaProbability: 1.0,
        bananaRank: 1,
        topClassIndex: bananaClassIndex,
        topProbability: 1.0,
      );
    }

    final bananaProb = probs[bananaClassIndex];
    int rank = 1;
    int topIdx = 0;
    double topProb = probs[0];

    for (int i = 0; i < probs.length; i++) {
      final p = probs[i];
      if (p > bananaProb) {
        rank++;
      }
      if (p > topProb) {
        topProb = p;
        topIdx = i;
      }
    }

    final relativeRatio = topProb > 0 ? (bananaProb / topProb) : 0.0;
    final isBanana =
        bananaProb >= minDirectBananaProbability ||
        (rank <= maxTopRankForBanana &&
            bananaProb >= minTopRankBananaProbability &&
            relativeRatio >= minTopRankRelativeRatio);

    return BananaGateResult(
      isBanana: isBanana,
      bananaProbability: bananaProb,
      bananaRank: rank,
      topClassIndex: topIdx,
      topProbability: topProb,
    );
  }

  @override
  Future<void> dispose() async {
    await _isolateInterpreter?.close();
    _isolateInterpreter = null;
    _interpreter?.close();
    _interpreter = null;
    _initFuture = null;
  }
}
