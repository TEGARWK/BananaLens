import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../data/models/scan_outcome.dart';
import 'ml_kit_fruit_detector.dart';
import 'on_device_image_preprocessor.dart';
import 'on_device_svm_classifier.dart';
import 'scan_service.dart';

/// On-device hybrid AI scanner combining:
/// 1. Google ML Kit Image Labeling (fruit/food pre-validation),
/// 2. TFLite MobileNetV3Small feature extractor (576 dims, isolate-executed),
/// 3. Masked HSV color descriptor (30 dims, isolate-executed),
/// 4. PCA + RBF SVM with Platt calibration (100% offline, no Python or .pkl).
class OnDeviceScanService implements ScanService {
  OnDeviceScanService({
    FruitObjectValidator? fruitValidator,
    Future<Float32List> Function(Float32List cnnInput)? extractCnnFeatures,
    Future<String> Function(String key)? loadString,
    Future<ByteData> Function(String key)? loadBinary,
    double minBananaKernelSimilarity = defaultMinBananaKernelSimilarity,
  }) : _fruitValidator = fruitValidator ?? MlKitFruitValidator(),
       _customExtractCnnFeatures = extractCnnFeatures,
       _loadString = loadString ?? rootBundle.loadString,
       _loadBinary = loadBinary ?? rootBundle.load,
       _minBananaKernelSimilarity = minBananaKernelSimilarity;

  /// Minimum RBF kernel similarity to the nearest banana support vector.
  /// Calibrated against banana support-vector distribution (median 0.83, p10 0.57)
  /// vs. non-banana green/yellow produce (e.g. avocado ~0.49).
  static const double defaultMinBananaKernelSimilarity = 0.54;

  static const String tfliteAssetPath =
      'assets/models/mobilenet_v3_extractor.tflite';
  static const String svmMetaAssetPath = 'assets/models/svm_pisang_meta.json';
  static const String svmWeightsAssetPath =
      'assets/models/svm_pisang_weights.bin';

  final FruitObjectValidator _fruitValidator;
  final Future<Float32List> Function(Float32List cnnInput)?
  _customExtractCnnFeatures;
  final Future<String> Function(String key) _loadString;
  final Future<ByteData> Function(String key) _loadBinary;
  final double _minBananaKernelSimilarity;

  OnDeviceSvmClassifier? _svmClassifier;
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  Future<void>? _initFuture;

  Future<OnDeviceSvmClassifier> _ensureSvmLoaded() async {
    if (_svmClassifier != null) return _svmClassifier!;
    final metaJson = await _loadString(svmMetaAssetPath);
    final weightsData = await _loadBinary(svmWeightsAssetPath);
    final weightsBytes = weightsData.buffer.asUint8List(
      weightsData.offsetInBytes,
      weightsData.lengthInBytes,
    );
    _svmClassifier = OnDeviceSvmClassifier.fromAssets(
      metaJson: metaJson,
      weightsBytes: weightsBytes,
    );
    return _svmClassifier!;
  }

  Future<void> _ensureTfliteLoaded() async {
    if (_customExtractCnnFeatures != null || _isolateInterpreter != null) {
      return;
    }
    _initFuture ??= () async {
      final options = InterpreterOptions()..threads = 2;
      final interpreter = await Interpreter.fromAsset(
        tfliteAssetPath,
        options: options,
      );
      _interpreter = interpreter;
      _isolateInterpreter = await IsolateInterpreter.create(
        address: interpreter.address,
        debugName: 'FruitLensMobileNetV3',
      );
    }();
    await _initFuture;
  }

  Future<Float32List> _extractCnn576(Float32List cnnInput) async {
    final custom = _customExtractCnnFeatures;
    if (custom != null) {
      return custom(cnnInput);
    }
    await _ensureTfliteLoaded();
    final iso = _isolateInterpreter!;
    final output = Float32List(576);
    await iso.run(cnnInput.buffer.asUint8List(), output.buffer);
    return output;
  }

  @override
  Future<ScanOutcome> scan(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return const ScanFailure('File foto tidak ditemukan di penyimpanan.');
    }

    try {
      // 1. Validasi objek buah/makanan secara on-device menggunakan Google ML Kit
      final validation = await _fruitValidator.validate(imagePath);
      debugPrint(
        'OnDeviceScanService ML Kit -> likelyFruit=${validation.isLikelyFruitOrFood}, '
        'confidence=${validation.fruitConfidence.toStringAsFixed(2)}, '
        'labels=${validation.detectedLabels}',
      );
      if (!validation.isLikelyFruitOrFood) {
        return const ScanUncertain();
      }

      // 2. Muat bobot SVM (3.3 MB binary) & gambar mentah
      final svm = await _ensureSvmLoaded();
      final rawBytes = await file.readAsBytes();

      // 3. Preprocessing gambar + Masked HSV (30 fitur) di background Isolate
      final hsvWeight = svm.hsvWeight;
      final preprocessed = await Isolate.run(
        () => OnDeviceImagePreprocessor.processImageBytes(
          rawBytes,
          hsvWeight: hsvWeight,
        ),
      );

      // 3b. Tolak buah non-pisang berwarna merah/oranye cerah/ungu dominan (jeruk, apel merah, stroberi, dll.)
      final pigment = preprocessed.pigmentRatios;
      if (pigment.activePixelCount >= 50 &&
          pigment.nonBananaVividRatio >= 0.45) {
        debugPrint(
          'OnDeviceScanService -> Rejected vivid non-banana color '
          'ratio=${pigment.nonBananaVividRatio.toStringAsFixed(2)}',
        );
        return const ScanUncertain();
      }

      // 4. Ekstraksi fitur CNN MobileNetV3Small (576 fitur) via TFLite Isolate
      final cnn576 = await _extractCnn576(preprocessed.cnnInputTensor);

      // 5. Klasifikasi PCA + RBF SVM + Platt Scaling + Kalibrasi Klorofil di background Isolate
      final prediction = await Isolate.run(
        () => svm.predict(
          cnn576,
          preprocessed.hsvFeatures,
          pigmentRatios: preprocessed.pigmentRatios,
        ),
      );
      debugPrint(
        'OnDeviceScanService SVM -> class=${prediction.predictedClass}, '
        'confidence=${prediction.confidence.toStringAsFixed(3)}, '
        'maxSim=${prediction.maxKernelSimilarity.toStringAsFixed(4)}, '
        'probs=${prediction.probabilities}',
      );

      // 5b. Tolak objek di luar distribusi pisang (OOD), misal alpukat/mangga/terong
      if (prediction.maxKernelSimilarity < _minBananaKernelSimilarity) {
        debugPrint(
          'OnDeviceScanService -> Rejected OOD non-banana '
          'maxSim=${prediction.maxKernelSimilarity.toStringAsFixed(4)} '
          '< ${_minBananaKernelSimilarity.toStringAsFixed(4)}',
        );
        return const ScanUncertain();
      }

      final classCount = prediction.probabilities.length;
      final uncertaintyThreshold = classCount <= 3 ? 0.35 : 0.25;
      if (prediction.confidence < uncertaintyThreshold) {
        return const ScanUncertain();
      }

      return ScanSuccess(
        fruitLabel: validation.detectedFruitType ?? 'banana',
        ripenessLabel: prediction.predictedClass,
        fruitConfidence: validation.fruitConfidence,
        ripenessConfidence: prediction.confidence,
        classProbabilities: prediction.probabilities,
      );
    } on FormatException catch (e) {
      return ScanFailure(e.message);
    } catch (e) {
      debugPrint('OnDeviceScanService error: $e');
      return const ScanFailure(
        'Foto tidak bisa diproses. Pastikan buah terlihat jelas lalu coba lagi.',
      );
    }
  }

  Future<void> dispose() async {
    await _isolateInterpreter?.close();
    _isolateInterpreter = null;
    _interpreter?.close();
    _interpreter = null;
    await _fruitValidator.dispose();
  }
}
